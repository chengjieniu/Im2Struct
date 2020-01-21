#include <windows.h>
#include "EngineOSG.h"
#include "depth.h"
#include "util.h"
#include <osgDB/ReadFile>
#include <osgDB/WriteFile>
#include <osg/MatrixTransform>
#include <osgGA/TrackballManipulator>
#include <GL/glu.h>
#include <osg/Hint>
#include <osg/Multisample>
#include <osg/ShadeModel>
#include <osg/ComputeBoundsVisitor>
#include <osgUtil/SmoothingVisitor>


#include <map>
struct NodeMeshDataPair;
map<string, NodeMeshDataPair> cache;


#include <osgUtil/Optimizer>

#define M_PI 3.14159265358979323846

//resize textures to power of two, otherwise OSG resizes them every rendering (even when retrieved from cache)
class MyTexture: public osgUtil::Optimizer::TextureVisitor {
public:
	MyTexture() :
		TextureVisitor(false, false, false, false, false, 1.0) {
	}

	void apply(osg::Node& node) {

		osg::StateSet* ss = node.getStateSet();
		if (ss && isOperationPermissibleForObject(&node) && isOperationPermissibleForObject(ss)) {
			apply(*ss);
		}

		traverse(node);
	}

	void apply(osg::Geode& geode) {
		if (!isOperationPermissibleForObject(&geode))
			return;

		osg::StateSet* ss = geode.getStateSet();

		if (ss && isOperationPermissibleForObject(ss)) {
			apply(*ss);
		}

		for (unsigned int i = 0; i < geode.getNumDrawables(); ++i) {
			osg::Drawable* drawable = geode.getDrawable(i);
			if (drawable) {
				ss = drawable->getStateSet();
				if (ss && isOperationPermissibleForObject(drawable)
						&& isOperationPermissibleForObject(ss)) {
					apply(*ss);
				}
			}
		}
	}

	void apply(osg::StateSet& stateset) {
		for (unsigned int i = 0; i < stateset.getTextureAttributeList().size(); ++i) {
			osg::StateAttribute* sa = stateset.getTextureAttribute(i, osg::StateAttribute::TEXTURE);
			osg::Texture* texture = dynamic_cast<osg::Texture*> (sa);
			if (texture && isOperationPermissibleForObject(texture)) {
				apply(*texture);
			}
		}
	}

	//TODO: either use the maxTextureSize for ensureValidSizeForTexturing(maxTextureSize) as done in Texture1D,
	//or call this before (not after) rendering the model for the first time
	//otherwise the first rendering is done with different maxTextureSize than the rest of the renderings
	//The problem is this cannot be run before a GL context is obtained, as the Image resizing code uses OpenGL
	void apply(osg::Texture& texture) {
		//		texture.setResizeNonPowerOfTwoHint(true);
		for (unsigned int i = 0; i < texture.getNumImages(); ++i) {
			osg::Image* im = texture.getImage(i);
			if (im) {
				im->ensureValidSizeForTexturing(512);
			}
		}

	}
};

//extracts mesh data
class GetMeshData: public osg::NodeVisitor {
	vector<GLfloat> vertices;
	vector<GLfloat> colors;
	vector<GLfloat> normals;
	int cbind;
	int nbind;
	bool cfirst;
	bool nfirst;
	bool colorsError;
	bool normalsError;
public:
	MeshData meshData;

	GetMeshData() :
		osg::NodeVisitor( // Traverse all children.
				osg::NodeVisitor::TRAVERSE_ALL_CHILDREN) {
		cfirst = nfirst = true;
		colorsError = normalsError = false;
	}

	// This method gets called for every node in the scene graph.
	virtual void apply(osg::Geode& node) {
		const osg::Geode::DrawableList dl = node.getDrawableList();
		osg::Geode::DrawableList::const_iterator cii;
		for (cii = dl.begin(); cii != dl.end(); cii++) {
			osg::ref_ptr<osg::Drawable> d = *cii;
			osg::Geometry *g = d->asGeometry();
			if (g != 0) {
				try {
					osg::Geometry::PrimitiveSetList psl = g->getPrimitiveSetList();
					osg::Geometry::PrimitiveSetList::const_iterator psli;
					for (psli = psl.begin(); psli != psl.end(); psli++) {
						const osg::ref_ptr<osg::PrimitiveSet> ps = *psli;
						if (ps->getMode() != osg::PrimitiveSet::TRIANGLES) {
							throw "Error: face data is not a triangle";
						}
					}

					osg::Array* va = g->getVertexArray();
					if (va == 0) {
						throw "Error: no vertices data";
					}
					sout << va->getNumElements() << endl;
					if (va->getDataType() != GL_FLOAT) {
						throw "Error: vertices data type is not GL_FLOAT";
					}
					if (va->getType() != osg::Array::Vec3ArrayType) {
						throw "Error: vertices data is not a triplet";

					}
					osg::Vec3Array* pos = static_cast<osg::Vec3Array*> (va);
					for (unsigned int i = 0; i < va->getNumElements(); i++) {
						vertices.push_back((*pos)[i][0]);
						vertices.push_back((*pos)[i][1]);
						vertices.push_back((*pos)[i][2]);
					}
				} catch (char const *e) {
					printf("%s\n", e);
					vertices.clear();
					normals.clear();
					colors.clear();
					return;
				}

				// if an error has previously occured then ignore all colors data
				if (!colorsError) {
					osg::Array* ca = g->getColorArray();
					try {
						if (ca == 0) {
							throw "Error: no color data";
						}
						sout << ca->getDataType() << tab << ca->getType() << tab
								<< ca->getNumElements() << tab << g->getColorBinding() << endl;
						if (cfirst) {
							cbind = g->getColorBinding();
							cfirst = false;
						} else if (cbind != g->getColorBinding()) {
							throw string("Error: color data is not " + toString(cbind) + " but "
									+ toString(g->getColorBinding())).c_str();
						}
						if (ca->getDataType() != GL_FLOAT) {
							throw "Error: color data type is not GL_FLOAT";

						}
						if (ca->getType() != osg::Array::Vec4ArrayType) {
							throw "Error: color data is not a quadlet";

						}
						osg::Vec4Array* pos4 = static_cast<osg::Vec4Array*> (ca);
						for (unsigned int i = 0; i < ca->getNumElements(); i++) {
							colors.push_back((*pos4)[i][0]);
							colors.push_back((*pos4)[i][1]);
							colors.push_back((*pos4)[i][2]);
							colors.push_back((*pos4)[i][3]);
						}
					} catch (char const *e) {
						colorsError = true;
						colors.clear();
						printf("%s\n", e);
						//continue to parse other data
					}
				}

				// if an error has previously occured then ignore all colors data
				if (!normalsError) {
					osg::Array* na = g->getNormalArray();
					try {
						if (na == 0) {
							throw "Error: no normal data";
						}
						sout << na->getDataType() << tab << na->getType() << tab
								<< na->getNumElements() << tab << g->getNormalBinding() << endl;
						if (nfirst) {
							nbind = g->getNormalBinding();
							nfirst = false;
						} else if (nbind != g->getNormalBinding()) {
							throw string("Error: normal data is not " + toString(nbind) + " but "
									+ toString(g->getNormalBinding())).c_str();
						}
						if (na->getDataType() != GL_FLOAT) {
							throw "Error: normal data type is not GL_FLOAT";

						}
						if (na->getType() != osg::Array::Vec3ArrayType) {
							throw "Error: normal data is not a triplet";

						}

						osg::Vec3Array* pos = static_cast<osg::Vec3Array*> (na);
						for (unsigned int i = 0; i < na->getNumElements(); i++) {
							normals.push_back((*pos)[i][0]);
							normals.push_back((*pos)[i][1]);
							normals.push_back((*pos)[i][2]);
						}
					} catch (char const *e) {
						normalsError = true;
						normals.clear();
						printf("%s\n", e);
						//continue to parse other data
					}
				}

				//        sout<<node.getName()<<"\t"<<node.getNumDrawables()<<endl;
			}
		}
		// Keep traversing the rest of the scene graph.
		traverse(node);
	}

	void set() {
		meshData.setVertices(vertices);
		meshData.setColors(colors);
		meshData.setCbind(cbind);
		meshData.setNormals(normals);
		meshData.setNbind(nbind);
	}
};

class MyValueVisitor: public osg::ValueVisitor {
public:
	osg::Vec3 _move;
	osg::Matrix _mult;

	void apply(osg::Vec3 &v) {
		v.set((v + _move) * _mult);
	}
};

class MyValueVisitorNormal: public osg::ValueVisitor {
public:
	osg::Vec3 _move;
	osg::Matrix _mult;

	void apply(osg::Vec3 &v) {
		v.set((v + _move) * _mult);
		//GL_NORMALIZE makes the following line unnecessary
		v.normalize();
	}
};

class MyGeometryVisitor: public osg::NodeVisitor {
public:
	MyValueVisitor mvv;
	MyValueVisitorNormal mvvn;
	bool transNormals;

	MyGeometryVisitor(osg::Vec3 _move, osg::Matrix _mult, bool _transNormals = false) :
		osg::NodeVisitor( // Traverse all children.
				osg::NodeVisitor::TRAVERSE_ALL_CHILDREN) {
		mvv._move = _move;
		mvv._mult = _mult;

		transNormals = _transNormals;
		if (transNormals) {
			double m[16];
			double mTransposed[16];
			osg::Matrix tmp;
			tmp.makeTranslate(_move);
			tmp = _mult * tmp;
			_move = osg::Vec3(0, 0, 0);

			osg::Matrix::value_type *mvmptr = osg::Matrix::inverse(tmp).ptr();
			//			osg::Matrix::value_type *mvmptr = mat.ptr();
			for (int i = 0; i < 16; i++) {
				m[i] = mvmptr[i];
			}
			transpose(m, 4, 4, mTransposed);
			mvvn._move = _move;
			mvvn._mult = osg::Matrix(mTransposed);
		}
	}

	void apply(osg::Geode& geode) {

		for (unsigned int i = 0; i < geode.getNumDrawables(); ++i) {
			osg::Geometry* geom = geode.getDrawable(i)->asGeometry();

			if (geom) {
				osg::Array* va = geom->getVertexArray();

				for (unsigned int j = 0; j < va->getNumElements(); ++j) {
					va->accept(j, mvv);
				}

				if (transNormals) {
					osg::Array* na = geom->getNormalArray();
					for (unsigned int j = 0; j < na->getNumElements(); ++j) {
						na->accept(j, mvvn);
					}
				}
				geom->dirtyBound();
			}

		}
		// Keep traversing the rest of the scene graph.
		traverse(geode);
	}
};

//verify that a mesh doesn't contain transform nodes
//these might cause trouble when run with A, R and T camera orientation arguments
class CheckTransform: public osg::NodeVisitor {
public:
	bool error;

	CheckTransform() :
		osg::NodeVisitor( // Traverse all children.
				osg::NodeVisitor::TRAVERSE_ALL_CHILDREN) {
		error = false;
	}

	virtual void apply(osg::Transform& node) {
		error = true;

		// Keep traversing the rest of the scene graph.
		//		traverse(node);

	}
};

class FlattenMatrixTransformsVisitor: public osg::NodeVisitor {
public:
	bool error;
	bool transNormals;
	FlattenMatrixTransformsVisitor(bool _transNormals = false) :
		osg::NodeVisitor( // Traverse all children.
				osg::NodeVisitor::TRAVERSE_ALL_CHILDREN) {
		error = false;
		transNormals = _transNormals;
	}

	virtual void apply(osg::Geode& node) {
		osg::NodePathList npl = node.getParentalNodePaths();
		if (npl.size() == 1) {
			osg::NodePath np = npl.at(0);
			osg::Matrix mat = osg::computeLocalToWorld(np);

			MyValueVisitor mvv;
			mvv._move = osg::Vec3(0, 0, 0);
			mvv._mult = mat;

			MyValueVisitorNormal mvvn;
			if (transNormals) {
				double m[16];
				double mTransposed[16];
				osg::Matrix::value_type *mvmptr = osg::Matrix::inverse(mat).ptr();
				//			osg::Matrix::value_type *mvmptr = mat.ptr();
				for (int i = 0; i < 16; i++) {
					m[i] = mvmptr[i];
				}
				transpose(m, 4, 4, mTransposed);
				mvvn._move = osg::Vec3(0, 0, 0);
				mvvn._mult = osg::Matrix(mTransposed);
			}
			for (unsigned int i = 0; i < node.getNumDrawables(); ++i) {
				osg::Geometry* geom = node.getDrawable(i)->asGeometry();

				if (geom) {
					osg::Array* va = geom->getVertexArray();
					for (unsigned int j = 0; j < va->getNumElements(); ++j) {
						va->accept(j, mvv);
					}

					if (transNormals) {
						osg::Array* na = geom->getNormalArray();
						for (unsigned int j = 0; j < na->getNumElements(); ++j) {
							na->accept(j, mvvn);
						}
					}

					geom->dirtyBound();
				}
			}
		} else {
			// multiple parents. cannot deal without creating more subgraphs
			error = true;
		}
		// Keep traversing the rest of the scene graph.
		traverse(node);
	}

};

class SetMatrixTransformsToIdentityVisitor: public osg::NodeVisitor {
public:

	SetMatrixTransformsToIdentityVisitor() :
		osg::NodeVisitor( // Traverse all children.
				osg::NodeVisitor::TRAVERSE_ALL_CHILDREN) {
	}

	virtual void apply(osg::MatrixTransform& node) {
		node.setMatrix(osg::Matrix());
		// Keep traversing the rest of the scene graph.
		traverse(node);
	}

};

struct NodeMeshDataPair {
	osg::ref_ptr<osg::Node> node;
	MeshData meshData;
};

void printMatrix(osg::Matrix m) {
	sout << m(0, 0) << tab << m(0, 1) << tab << m(0, 2) << tab << m(0, 3) << endl;
	sout << m(1, 0) << tab << m(1, 1) << tab << m(1, 2) << tab << m(1, 3) << endl;
	sout << m(2, 0) << tab << m(2, 1) << tab << m(2, 2) << tab << m(2, 3) << endl;
	sout << m(3, 0) << tab << m(3, 1) << tab << m(3, 2) << tab << m(3, 3) << endl;
}

osg::Matrix calcLookAt(osg::ref_ptr<osgViewer::Viewer> viewer) {
	osg::BoundingSphere bs = viewer->getSceneData()->getBound();
	//center should be 0,0,0 after the model has been centered. otherwise problems occur with later rotations
	osg::Vec3 center = bs.center();
	double radius = bs.radius();

	osg::Vec3 eye = center + osg::Vec3(0.0, -3.5f * radius, 0.0f);
	osg::Vec3 up = osg::Vec3(0.0f, 0.0f, 1.0f);
	//	osg::Vec3 eye = center + osg::Vec3(0.0, 0., -3.5f * radius);
	//	osg::Vec3 up = osg::Vec3(0.0f, 1.0f, 0.0f);
	return osg::Matrix::lookAt(eye, center, up);
}

//the viewMatrix in osg doesn't hold the final model view matrix as in OpenGL.
//need to add to osg's viewMatrix other transformation which are done on graph.
//not so easy to calculate...
//in validateModelView we verify that it is indeed correct
//Actually, if using FlattenMatrixTransformsVisitor and SetMatrixTransformsToIdentityVisitor then the modelmatrix
//is just the center translation (from centerModel)
osg::Matrix getModelMatrix(osg::ref_ptr<osgViewer::Viewer> viewer) {
	osg::Matrix mm;
	//should probably traverse all children
	osg::Node *node = viewer->getSceneData();
	if (NULL != node) {
		osg::Group *gr;
		do {
			gr = node->asGroup();
			if (gr != NULL && gr->getNumChildren() > 0) {
				node = gr->getChild(0);
			}

		} while (NULL != gr && gr->getNumChildren() > 0);
		if (NULL != node) {
			osg::MatrixList ml = node->getWorldMatrices();
			for (osg::MatrixList::const_iterator mli = ml.begin(); mli != ml.end(); mli++) {
				mm = mm * (*mli);

			}
		}
	}

	return mm;
}

osg::Matrix getCameraMatrix(osg::ref_ptr<osgViewer::Viewer> viewer) {
	osg::Matrix vm = viewer->getCamera()->getViewMatrix();
	osg::Matrix mm = getModelMatrix(viewer);
	osg::Matrix projectionMatrix = viewer->getCamera()->getProjectionMatrix();
	osg::Matrix windowMatrix = viewer->getCamera()->getViewport()->computeWindowMatrix();

	return mm * vm * projectionMatrix * windowMatrix;
}

osg::Matrix getInverseCameraMatrix(osg::ref_ptr<osgViewer::Viewer> viewer) {
	osg::Matrix inverseCameraMatrix(osg::Matrix::inverse(getCameraMatrix(viewer)));
	return inverseCameraMatrix;
}

void unProjectImage(osg::ref_ptr<osgViewer::Viewer> viewer, GLfloat *depth,
		GLdouble *unprojectOutput, GLdouble* inversematrix_lj) {
	if (NULL == unprojectOutput) {
		return;
	}

	int width = (unsigned int) viewer->getCamera()->getViewport()->width();
	int height = (unsigned int) viewer->getCamera()->getViewport()->height();

	osg::Matrix inverseCameraMatrix = getInverseCameraMatrix(viewer);

	for (int winy = height - 1; winy >= 0; winy--) {
		for (int winx = 0; winx < width; winx++) {
			GLfloat winz = depth[winy * width + winx];
			osg::Vec3 worldPos(0, 0, 0);
			if (winz > 0 && winz < 1) {
				// for some reason using (winx, winy, winz) results in a wrong winy when reprojecting
				// using A*[R T']. so using winy+1 instead
				// (reprojecting using glProject or projectPoint works with (winx, winy, winz) though.)
				osg::Vec3 oglWinPos(winx, winy + 1, winz);
				worldPos = oglWinPos * inverseCameraMatrix;
			}
			int y = height - 1 - winy;
			unprojectOutput[winx * height + y] = worldPos.x();
			unprojectOutput[height * width + winx * height + y] = worldPos.y();
			unprojectOutput[height * width * 2 + winx * height + y] = worldPos.z();
		}
	}
    osg::Matrix::value_type *projptr = inverseCameraMatrix.ptr();

    inversematrix_lj[0] = projptr[0];
    inversematrix_lj[1] = projptr[4];
    inversematrix_lj[2] = projptr[8];
    inversematrix_lj[3] = projptr[1];
    inversematrix_lj[4] = projptr[5];
    inversematrix_lj[5] = projptr[9];
    inversematrix_lj[6] = projptr[2];
    inversematrix_lj[7] = projptr[6];
    inversematrix_lj[8] = projptr[10];

}

osg::Vec2 projectPoint(osg::ref_ptr<osgViewer::Viewer> viewer, osg::Vec3 worldPos) {
	osg::Vec3f vec = worldPos * getCameraMatrix(viewer);
	int height = (unsigned int) viewer->getCamera()->getViewport()->height();
	double winy = (height - vec.y() - 1);
	sout << vec.x() << tab << winy << endl;
	return osg::Vec2(vec.x(), winy);
}

osg::Vec3 unProjectPoint(osg::ref_ptr<osgViewer::Viewer> viewer, GLfloat *depth, int winx, int winy) {
	int width = (unsigned int) viewer->getCamera()->getViewport()->width();
	int height = (unsigned int) viewer->getCamera()->getViewport()->height();

	winy = (height - winy - 1);

	GLfloat winz = depth[winy * width + winx];
	if (winz == 0 || winz == 1) {
		sout << "unproject point: winz= " << winz << endl;
		return osg::Vec3();
	}

	sout << "unproject point: oglwinx,y,z: " << winx << tab << winy << tab << winz << endl;
	osg::Vec3 oglWinPos(winx, winy, winz);

	osg::Matrix inverseCameraMatrix = getInverseCameraMatrix(viewer);

	osg::Vec3 worldPos = oglWinPos * inverseCameraMatrix;
	sout << "vertex is x,y,z: " << worldPos.x() << tab << worldPos.y() << tab << worldPos.z()
			<< tab << endl;
	//	projectPoint(viewer, worldPos);
	return worldPos;

}

void EngineOSG::setupSphereOrientation() {
	osg::Matrix m = calcLookAt(viewer);
	osg::Matrix trans = osg::Matrix::translate(0, distance, 0);
	osg::Matrix rotx = osg::Matrix::rotate(elevation, osg::Vec3(1., 0., 0.));
	osg::Matrix roty = osg::Matrix::rotate(yaw, osg::Vec3(0., 1., 0.));
	osg::Matrix rotz = osg::Matrix::rotate(azimuth, osg::Vec3(0., 0., 1.));
	if (deg_order == "zyx") {
		viewer->getCamera()->setViewMatrix(rotz * roty * rotx * trans * m);
	} else if (deg_order == "xyz") {
		viewer->getCamera()->setViewMatrix(rotx * roty * rotz * trans * m);
	} else if (deg_order == "xzy") {
		viewer->getCamera()->setViewMatrix(rotx * rotz * roty * trans * m);
	} else {
		viewer->getCamera()->setViewMatrix(rotz * rotx * roty * trans * m);
	}

	//OSG's default projection matrix has y scaling larger than x. we correct it here.
	osg::Matrix opm = viewer->getCamera()->getProjectionMatrix();
	opm(1, 1) = opm(0, 0);
	viewer->getCamera()->setProjectionMatrix(opm);

}

void setupMatricesOrientation(osg::ref_ptr<osgViewer::Viewer> viewer, int width, int height,
		double *A, double *R, double *T) {
	sout << "using matrices" << endl;
	double mv[16];
	double projectionMatrix[16];
	getOpenGLMatrices(A, R, T, width, height, mv, projectionMatrix);

	sout << "modelview:" << endl;
	osg::Matrix mvm(mv);
	printMatrix(mvm);

	osg::Matrix mm(getModelMatrix(viewer));
	osg::Matrix mmi(osg::Matrix::inverse(mm));
	osg::Matrix oviewm(mmi * mvm);
	sout << "calculated view:" << endl;
	printMatrix(oviewm);
	viewer->getCamera()->setViewMatrix(oviewm);

	sout << "calculated projection:" << endl;
	printMatrix(projectionMatrix, 4, 4);
	//uncomment the next line in order to tell OSG to use the calculated near and far values instead of OSG's auto-calculation
	//OSG's auto-calculation seems better...Also the next line somehow causes the depth buffer to be ~0
	//	viewer->getCamera()->setComputeNearFarMode(osg::CullSettings::DO_NOT_COMPUTE_NEAR_FAR);
	//	viewer->getCamera()->setComputeNearFarMode(osg::CullSettings::COMPUTE_NEAR_FAR_USING_PRIMITIVES);
	osg::Matrix opm(projectionMatrix);
	viewer->getCamera()->setProjectionMatrix(opm);

	//if using distortion then might have to do cvundistort after projection
}

void printMVPInfo(osg::ref_ptr<osgViewer::Viewer> viewer) {
	if (DEBUG) {
		osg::Matrix viewMatrix = viewer->getCamera()->getViewMatrix();
		osg::Matrix mm = getModelMatrix(viewer);
		sout << "view" << endl;
		printMatrix(viewMatrix);
		sout << "model" << endl;
		printMatrix(mm);
		sout << "projection" << endl;
		printMatrix(viewer->getCamera()->getProjectionMatrix());
		sout << "possibly modelview" << endl;
		printMatrix(mm * viewMatrix);
		GLdouble modelview[QUADLET * QUADLET];
		glGetDoublev(GL_MODELVIEW_MATRIX, modelview);
		GLdouble projection[QUADLET * QUADLET];
		glGetDoublev(GL_PROJECTION_MATRIX, projection);
		sout << "OGL modelview" << endl;
		printMatrix(modelview, QUADLET, QUADLET);
		sout << "OGL projection" << endl;
		printMatrix(projection, QUADLET, QUADLET);
	}
}

// verifies that OpenGL modelview matrix is equal to OSG's (since we manually calculate OSG's model matrix)
void validateModelView(osg::ref_ptr<osgViewer::Viewer> viewer) {
	osg::Matrix vm = viewer->getCamera()->getViewMatrix();
	osg::Matrix mm = getModelMatrix(viewer);
	osg::Matrix mvm(mm * vm);
	GLdouble OGLmvm[QUADLET * QUADLET];
	glGetDoublev(GL_MODELVIEW_MATRIX, OGLmvm);
	osg::Matrix::value_type *OSGmvm = mvm.ptr();
	osg::Matrix::value_type MAX_MVM_DIFF_ERR = 0.3;
	for (unsigned int i = 0; i < QUADLET * QUADLET; i++) {
		if (fabs(OSGmvm[i] - OGLmvm[i]) > MAX_MVM_DIFF_ERR) {
			throw "Error: OGL modelview is different than OSG's. Either OGL modelview is the identity matrix or could not calculate the model transformations matrix.";
		}
	}
}

//just for comparison with unProjectPoint
void GetOGLPos(int x, int y) {
	GLint viewport[4];
	GLdouble modelview[16];
	GLdouble projection[16];
	GLfloat winX, winY, winZ;
	GLdouble posX, posY, posZ;

	glGetDoublev(GL_MODELVIEW_MATRIX, modelview);
	glGetDoublev(GL_PROJECTION_MATRIX, projection);
	glGetIntegerv(GL_VIEWPORT, viewport);

	winX = (float) x;
	winY = (float) viewport[3] - (float) y - 1;
	glReadPixels(x, int(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &winZ);
	if (winZ == 0 || winZ == 1) {
		sout << "GetOGLPos: winz= " << winZ << endl;
		return;
	}
	sout << winX << tab << winY << tab << winZ << endl;

	gluUnProject(winX, winY, winZ, modelview, projection, viewport, &posX, &posY, &posZ);

	sout << posX << tab << posY << tab << posZ << endl;
}

//just for comparison with projectPoint
void GetOGLProj(double posX, double posY, double posZ) {
	GLint viewport[4];
	GLdouble modelview[16];
	GLdouble projection[16];
	GLdouble winX, winY, winZ;

	glGetDoublev(GL_MODELVIEW_MATRIX, modelview);
	glGetDoublev(GL_PROJECTION_MATRIX, projection);
	glGetIntegerv(GL_VIEWPORT, viewport);

	sout << posX << tab << posY << tab << posZ << endl;

	gluProject(posX, posY, posZ, modelview, projection, viewport, &winX, &winY, &winZ);

	sout << winX << tab << winY << tab << winZ << endl;

}

class CaptureCB: public osg::Camera::DrawCallback {
	EngineOSG engine;
public:
	CaptureCB(EngineOSG _engine) :
		engine(_engine) {
	}

	virtual void operator()(osg::RenderInfo& ri) const {
		bool foundInCache = USE_CACHE && (cache.find(engine.filename) != cache.end());
		if (!foundInCache) {
			NodeMeshDataPair gmdPair;
			gmdPair.node = engine.viewer->getSceneData();
			gmdPair.meshData = engine.meshData;
			cache.insert(pair<string, NodeMeshDataPair> (engine.filename, gmdPair));
			MyTexture tex;
			engine.viewer->getSceneData()->accept(tex);
		}
		validateModelView(engine.viewer);
		//		osg::Viewport *p = viewer->getCamera()->getViewport();
		int width = engine.width;
		int height = engine.height;
		osg::ref_ptr<osg::Image> renderedImage = new osg::Image;
		//		renderedImage->readPixels(p->x(), p->y(), p->width(), p->height(), GL_RGB, GL_UNSIGNED_BYTE);
		renderedImage->readPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE);
		getRenderedImage(renderedImage->data(), width, height, engine.imageOutput);
		osg::ref_ptr<osg::Image> depthImage(new osg::Image);
		depthImage->readPixels(0, 0, width, height, GL_DEPTH_COMPONENT, GL_FLOAT);
		double *imgDepth = new double[width * height];
		CopyAndModifyDepth((GLfloat*) depthImage->data(), width, height, imgDepth);
		getDepthOutput(imgDepth, width, height, engine.depthOutput);
		if (engine.getUnproject) {
			unProjectImage(engine.viewer, (GLfloat*) depthImage->data(), engine.unprojectOutput, engine.AOutput);
		}
		if (engine.writeFiles) {
			osgDB::writeImageFile(*renderedImage, "rendered.png");
			WriteDepthFile("depth.pgm", imgDepth, width, height);
		}
		delete[] imgDepth;
		printMVPInfo(engine.viewer);
		engine.viewer->setDone(true);

	}

private:
	virtual ~CaptureCB() {
	}

};

osg::ref_ptr<osg::Geode> drawFromData(osg::ref_ptr<osgViewer::Viewer> viewer, MeshData &meshData) {
	const vector<GLfloat> vertices = meshData.getVertices();
	const vector<GLfloat> &colors = meshData.getColors();
	const osg::Geometry::AttributeBinding cbind =
			(osg::Geometry::AttributeBinding) meshData.getCbind();
	const vector<GLfloat> &normals = meshData.getNormals();
	const osg::Geometry::AttributeBinding nbind =
			(osg::Geometry::AttributeBinding) meshData.getNbind();
	if (vertices.empty()) {
		throw "Error: no vertices";
	}
	if (vertices.size() % TRIPLET != 0) {
		throw "Error: vertices data is not a triplet";
	}

	if (colors.size() % QUADLET != 0) {
		throw "Error: color data is not a quadlet";
	}

	if (normals.size() % TRIPLET != 0) {
		throw "Error: normal data is not a triplet";
	}

	osg::ref_ptr<osg::Geometry> geom = new osg::Geometry;
	osg::ref_ptr<osg::Vec3Array> v = new osg::Vec3Array;
	geom->setVertexArray(v.get());

	for (vector<GLfloat>::const_iterator vi = vertices.begin(); vi != vertices.end();) {
		//evaluation order is not guarenteed, so can't use v->push_back(osg::Vec3(*vi++, *vi++, *vi++));
		GLfloat x = *vi++;
		GLfloat y = *vi++;
		GLfloat z = *vi++;
		v->push_back(osg::Vec3(x, y, z));
	}
	sout << v->size() << endl;
	geom->addPrimitiveSet(new osg::DrawArrays(osg::PrimitiveSet::TRIANGLES, 0, v->size()));

	if (!colors.empty()) {
		osg::ref_ptr<osg::Vec4Array> c = new osg::Vec4Array;
		geom->setColorArray(c.get());

		for (vector<GLfloat>::const_iterator ci = colors.begin(); ci != colors.end();) {
			GLfloat x = *ci++;
			GLfloat y = *ci++;
			GLfloat z = *ci++;
			GLfloat w = *ci++;
			c->push_back(osg::Vec4(x, y, z, w));
		}
		geom->setColorBinding(cbind);
	}

	if (!normals.empty()) {
		osg::ref_ptr<osg::Vec3Array> n = new osg::Vec3Array;
		geom->setNormalArray(n.get());
		for (vector<GLfloat>::const_iterator ni = normals.begin(); ni != normals.end();) {
			GLfloat x = *ni++;
			GLfloat y = *ni++;
			GLfloat z = *ni++;
			n->push_back(osg::Vec3(x, y, z));
		}
		geom->setNormalBinding(nbind);
		sout << n->size() << endl;
	}

	osg::ref_ptr<osg::Geode> geode = new osg::Geode;
	geode->addDrawable(geom.get());

	viewer->setSceneData(geode.get());
	return geode;
}

void EngineOSG::drawPoints(vector<GLfloat> &vertices) {
	if (vertices.empty()) {
		throw "Error: no vertices";
	}
	if (vertices.size() % TRIPLET != 0) {
		throw "Error: vertices data is not a triplet";
	}

	osg::ref_ptr<osg::Geometry> geom = new osg::Geometry;
	osg::ref_ptr<osg::Vec3Array> v = new osg::Vec3Array;
	geom->setVertexArray(v.get());

	for (vector<GLfloat>::const_iterator vi = vertices.begin(); vi != vertices.end();) {
		//evaluation order is not guarenteed, so can't use v->push_back(osg::Vec3(*vi++, *vi++, *vi++));
		GLfloat x = *vi++;
		GLfloat y = *vi++;
		GLfloat z = *vi++;
		v->push_back(osg::Vec3(x, y, z));
	}
	sout << v->size() << endl;
	geom->addPrimitiveSet(new osg::DrawArrays(osg::PrimitiveSet::POINTS, 0, v->size()));

	osg::ref_ptr<osg::Geode> geode = new osg::Geode;
	geode->addDrawable(geom.get());

	viewer->setSceneData(geode.get());
}

void drawFromFile(osg::ref_ptr<osgViewer::Viewer> viewer, string filename) {
	osg::ref_ptr<osg::Node> loadedModel = osgDB::readNodeFile(filename);

	if (!loadedModel) {
		sout << ": No data loaded." << endl;
		return;
	}
	viewer->setSceneData(loadedModel.get());

}

void initOnScreen(osg::ref_ptr<osgViewer::Viewer> viewer) {

	osg::Matrix m = calcLookAt(viewer);
	double distance = 0;

	//azimuth = 0 and increasing elevation rotates around one axis
	//azimuth = M_PI/2 and increasing elevation rotates around the second axis
	//elevation = 0 and increasing azimuth rotates around the third axis
	double elevation = 0;
	//	double azimuth = 0;
	double azimuth = M_PI / 2;

	osg::Matrix trans = osg::Matrix::translate(0, distance, 0);
	while (!viewer->done()) {
		osg::Matrix rot = osg::Matrix::rotate(elevation, osg::Vec3(1., 0., 0.));
		osg::Matrix rot2 = osg::Matrix::rotate(azimuth, osg::Vec3(0., 0., 1.));
		elevation += 0.01;

		viewer->getCamera()->setViewMatrix(rot2 * rot * trans * m);
		viewer->frame();
	}

}

EngineOSG::EngineOSG() :
	viewer(new osgViewer::Viewer) {
}

EngineOSG::~EngineOSG() {
}

void EngineOSG::init() {
}

void normalizeModel(osg::ref_ptr<osg::Node> node) {
	osg::ComputeBoundsVisitor cbbv;
	node->accept(cbbv);
	osg::BoundingBox bb = cbbv.getBoundingBox();

	osg::Matrix sm;
	osg::Vec3 sz = bb._max - bb._min;
	osg::Vec3::value_type maxDim = max(max(sz.x(), sz.y()), sz.z());
	sm.makeScale(osg::Vec3(1 / maxDim, 1 / maxDim, 1 / maxDim));

	MyGeometryVisitor mgv(-bb._min, sm);
	node->accept(mgv);

	//verify
	osg::ComputeBoundsVisitor cbbv2; // must use a new visitor instance
	node->accept(cbbv2);
	bb = cbbv2.getBoundingBox();
	sout << bb._max.x() << tab << bb._max.y() << tab << bb._max.z() << tab << bb._min.x() << tab
			<< bb._min.y() << tab << bb._min.z() << endl;

}

osg::ref_ptr<osg::Node> centerModel(osg::ref_ptr<osg::Node> node) {

	osg::BoundingSphere bs = node->getBound();
	osg::Vec3 center = bs.center();
	if (DEBUG) {
		sout << "center is at: ";
		sout << center.x() << tab << center.y() << tab << center.z() << endl;
	}

	osg::ref_ptr<osg::MatrixTransform> mt = new osg::MatrixTransform;
	osg::Matrix m;
	m.makeTranslate(-center);
	mt->setMatrix(m);
	mt->addChild(node.get());
	return mt;

}

void centerModelNew(osg::ref_ptr<osg::Node> node) {

	osg::BoundingSphere bs = node->getBound();
	osg::Vec3 center = bs.center();
	if (DEBUG) {
		sout << "center is at: ";
		sout << center.x() << tab << center.y() << tab << center.z() << endl;
	}

	MyGeometryVisitor mgv(-center, osg::Matrix());
}

void EngineOSG::drawFromFileAndData() {
	osg::ref_ptr<osg::Node> loadedModel;

	bool foundInCache = USE_CACHE && (cache.find(filename) != cache.end());
	if (!USE_CACHE || !foundInCache) {
        
        osgDB::Options  *a = new osgDB::Options(std::string("noTriStripPolygons noTesselateLargePolygons generateFacetNormals"));
		loadedModel = osgDB::readNodeFile(filename, a);

		if (!loadedModel) {
			string str = "Error: could not process file: ";
			str += filename;
			throw str.c_str();
		}
		osgUtil::Optimizer::TextureVisitor tv(true, false, false, false, false, false);
		//do not unref textures
		loadedModel->accept(tv);

		bool FIX_MODEL = false;
		if (FIX_MODEL) {
			cerr << "Fixing" << endl;

			//if normals are wrong after this (with and without SmoothingVisitor), then run
			//osgconv with full optimization on the model first, and use the converted model as input
			//OSG_NOTIFY_LEVEL=DEBUG OSG_OPTIMIZER="FLATTEN_STATIC_TRANSFORMS | FLATTEN_STATIC_TRANSFORMS_DUPLICATING_SHARED_SUBGRAPHS | REMOVE_REDUNDANT_NODES |  COMBINE_ADJACENT_LODS |     SHARE_DUPLICATE_STATE |     MERGE_GEOMETRY |            MERGE_GEODES |              SPATIALIZE_GROUPS  |        COPY_SHARED_NODES  |        TRISTRIP_GEOMETRY |         OPTIMIZE_TEXTURE_SETTINGS | REMOVE_LOADED_PROXY_NODES | TESSELLATE_GEOMETRY |       CHECK_GEOMETRY |            FLATTEN_BILLBOARDS |        TEXTURE_ATLAS_BUILDER |     STATIC_OBJECT_DETECTION " osgconv model.dae 
			//or:
			//osgconv --simplify 1 model.dae 
			FlattenMatrixTransformsVisitor fmtv(true);
			loadedModel->accept(fmtv);
			SetMatrixTransformsToIdentityVisitor smtv;
			loadedModel->accept(smtv);
			normalizeModel(loadedModel);
			//add to normalizeModel() and later divide the zoom distance by it sout << "maxDim: " << maxDim <<endl;

			loadedModel = centerModel(loadedModel);
			//		centerModelNew(loadedModel);

			//This does not seem to work from Matlab, only from outside
			//this should fix normals. alternatively use the visitors with transNormals=true
//					osgUtil::SmoothingVisitor sv;
//					loadedModel->accept(sv);

			osgDB::writeNodeFile(loadedModel.operator *(),filename+".converted.osg");
		} else {
			loadedModel = centerModel(loadedModel);
		}

		if (filename.rfind(".wrl") != filename.npos) {
			sout << "extracting mesh data" << endl;
			GetMeshData gmd;
			loadedModel->accept(gmd);
			gmd.set();
			meshData.copy(gmd.meshData);
			loadedModel = drawFromData(viewer, meshData);
		}
	}

	if (USE_CACHE) {
		NodeMeshDataPair gmdPair;
		if (!foundInCache) {
			sout << filename << " loaded" << endl;
		} else {
			gmdPair = cache.find(filename)->second;
			loadedModel = gmdPair.node;
			meshData.copy(gmdPair.meshData);
			sout << filename << " found in cache" << endl;
		}
	}
	viewer->setSceneData(loadedModel.get());
}

void EngineOSG::initDataFromFile() {
	drawFromFileAndData();
}

void EngineOSG::initData() {
	drawFromData(viewer, meshData);
}

void EngineOSG::getIntrisnicMatrix() {
	if (AOutput == NULL) {
		return;
	}
	osg::Matrix proj = viewer->getCamera()->getProjectionMatrix();
	osg::Matrix vm = viewer->getCamera()->getViewMatrix();
	osg::Matrix mm = getModelMatrix(viewer);
	osg::Matrix mvm(mm * vm);
	double mv[16];
	double projectionMatrix[16];
	osg::Matrix::value_type *mvmptr = mvm.ptr();
	for (int i = 0; i < 16; i++) {
		mv[i] = mvmptr[i];
	}
	osg::Matrix::value_type *projptr = proj.ptr();
	for (int i = 0; i < 16; i++) {
		projectionMatrix[i] = projptr[i];
	}

	double A[9];
	double R[9];
	double T[3];
	getCameraMatricesFromOpenGL(A, R, T, width, height, mv, projectionMatrix);
	transpose(A, 3, 3, AOutput);
	if (ROutput == NULL) {
		return;
	}
	transpose(R, 3, 3, ROutput);
	if (TOutput == NULL) {
		return;
	}
	transpose(T, 1, 3, TOutput);

}

void EngineOSG::initCamera() {
	if (offScreen) {
		viewer->getCamera()->setFinalDrawCallback(new CaptureCB(*this));
	}
	if (lighting) {
		viewer->getCamera()->getOrCreateStateSet()->setMode(GL_LIGHTING,
				osg::StateAttribute::OVERRIDE | osg::StateAttribute::OFF);
	}

	//this just normalizes each normal to unit length. it doesn't re-calculate it
	viewer->getCamera()->getOrCreateStateSet()->setMode(GL_NORMALIZE, osg::StateAttribute::ON);
    
//     osg::ref_ptr<osg::ShadeModel> shadeModel = new osg::ShadeModel(osg::ShadeModel::SMOOTH); 
//     viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(shadeModel.get(),osg::StateAttribute::OVERRIDE | osg::StateAttribute::ON);

	osg::ref_ptr<osg::Hint> persCorrect = new osg::Hint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(persCorrect.get(),
			osg::StateAttribute::ON);

	viewer->getCamera()->setCullingMode(osg::CullSettings::NO_CULLING);

	if (sphereOrientation) {
		setupSphereOrientation();
	} else {
		setupMatricesOrientation(viewer, width, height, A, R, T);
	}
	getIntrisnicMatrix();

}

class MyManipulator: public osgGA::TrackballManipulator {
	osg::Matrix mat;
public:

	MyManipulator(osg::Matrix m) :
		TrackballManipulator(), mat(m) {
	}

	osg::Matrixd getMatrix() const {
		return TrackballManipulator::getMatrix() * mat;
	}

	osg::Matrixd getInverseMatrix() const {
		return osg::Matrix::inverse(getMatrix());
	}

};

class KeyboardEventHandler: public osgGA::GUIEventHandler {
	EngineOSG engine;
public:

	KeyboardEventHandler(EngineOSG _engine) :
		engine(_engine) {
		increment = osg::DegreesToRadians(5.0);
		origDistance = engine.distance;
		distanceInc = engine.distanceInc;
	}

	virtual bool handle(const osgGA::GUIEventAdapter& ea, osgGA::GUIActionAdapter&) {
		osg::ref_ptr<osg::Hint> persCorrect = new osg::Hint(GL_PERSPECTIVE_CORRECTION_HINT,
				GL_NICEST);
		osg::ref_ptr<osg::Hint> persNoCorrect = new osg::Hint(GL_PERSPECTIVE_CORRECTION_HINT,
				GL_FASTEST);
		switch (ea.getEventType()) {
		case (osgGA::GUIEventAdapter::KEYDOWN): {
			switch (ea.getKey()) {
			case osgGA::GUIEventAdapter::KEY_Up:
				engine.elevation += increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Down:
				engine.elevation -= increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Right:
				engine.azimuth += increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Left:
				engine.azimuth -= increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Page_Up:
				engine.yaw += increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Page_Down:
				engine.yaw -= increment;
				break;
			case osgGA::GUIEventAdapter::KEY_Home:
				engine.distance += distanceInc;
				break;
			case osgGA::GUIEventAdapter::KEY_End:
				engine.distance -= distanceInc;
				break;
			case osgGA::GUIEventAdapter::KEY_Space:
				engine.elevation = 0;
				engine.azimuth = 0;
				engine.yaw = 0;
				engine.distance = origDistance;
				break;
			case osgGA::GUIEventAdapter::KEY_F1:
				engine.viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(
						persCorrect.get(), osg::StateAttribute::ON);
				break;
			case osgGA::GUIEventAdapter::KEY_F2:
				engine.viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(
						persCorrect.get(), osg::StateAttribute::OVERRIDE | osg::StateAttribute::OFF);
				break;
			case osgGA::GUIEventAdapter::KEY_F3:
				engine.viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(
						persNoCorrect.get(), osg::StateAttribute::ON);
				break;
			case osgGA::GUIEventAdapter::KEY_F4:
				engine.viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(
						persNoCorrect.get(), osg::StateAttribute::OVERRIDE
								| osg::StateAttribute::OFF);
				break;
			case 'l':
				engine.viewer->getCamera()->getOrCreateStateSet()->setMode(GL_LIGHTING,
						osg::StateAttribute::OVERRIDE | osg::StateAttribute::OFF);
				break;
			case 'L':
				engine.viewer->getCamera()->getOrCreateStateSet()->setMode(GL_LIGHTING,
						osg::StateAttribute::ON);
				break;
			case 'b':
				engine.viewer->getCamera()->getOrCreateStateSet()->setMode(GL_CULL_FACE,
						osg::StateAttribute::OVERRIDE | osg::StateAttribute::OFF);
				break;
			case 'B':
				engine.viewer->getCamera()->getOrCreateStateSet()->setMode(GL_CULL_FACE,
						osg::StateAttribute::ON);
				break;
			}
			int degx = int(osg::RadiansToDegrees(engine.elevation)) % 360;
			degx = degx < 0 ? 360 + degx : degx;
			int degy = int(osg::RadiansToDegrees(engine.azimuth)) % 360;
			degy = degy < 0 ? 360 + degy : degy;
			int degz = int(osg::RadiansToDegrees(engine.yaw)) % 360;
			degz = degz < 0 ? 360 + degz : degz;
			cout << "(" << degx << "," << degy << "," << degz << ")" << tab << "distance: "
					<< engine.distance << endl;
			engine.setupSphereOrientation();
			return true;
		}

		default:
			return false;
		}
	}

private:
	double increment;
	double origDistance;
	double distanceInc;
	virtual ~KeyboardEventHandler() {
	}

};

void EngineOSG::initCanvas() {
#ifdef INIT_ONCE
	if (!_myinit) {
		_myinit = true;
#endif
	int x = 0;
	int y = 0;
	osg::ref_ptr<osg::GraphicsContext::Traits> traits = new osg::GraphicsContext::Traits;
	traits->x = x;
	traits->y = y;
	traits->width = width;
	traits->height = height;
    osg::DisplaySettings::instance()->setNumMultiSamples(4);
    traits->samples=16;
    osg::Multisample* pms=new osg::Multisample;
    pms->setSampleCoverage(1,true);
    viewer->getCamera()->getOrCreateStateSet()->setAttributeAndModes(pms,osg::StateAttribute::ON);
	if (offScreen) {
		traits->windowDecoration = false;
		traits->doubleBuffer = true;
		traits->pbuffer = true;
	} else {
		traits->windowDecoration = true;
		traits->doubleBuffer = true;
		traits->pbuffer = false;
	}
	traits->sharedContext = 0;
	traits->alpha = 8;
	traits->readDISPLAY();
    traits->setUndefinedScreenDetailsToDefaultScreen();
    
	osg::GraphicsContext* _gc = osg::GraphicsContext::createGraphicsContext(traits.get());

	if (!_gc) {
		osg::notify(osg::NOTICE)
				<< "Failed to create pbuffer, failing back to normal graphics window." << endl;

		traits->pbuffer = false;
		_gc = osg::GraphicsContext::createGraphicsContext(traits.get());
	}
	viewer->getCamera()->setGraphicsContext(_gc);
	viewer->getCamera()->setViewport(new osg::Viewport(x, y, width, height));
	viewer->getCamera()->setClearColor(osg::Vec4(1, 1, 1, 1));

	if (!offScreen && !viewer->getCameraManipulator() && viewer->getCamera()->getAllowEventFocus()) {
		viewer->addEventHandler(new KeyboardEventHandler(*this));
	}

	viewer->setThreadingModel(osgViewer::ViewerBase::SingleThreaded);
	viewer->realize();
	viewer->setReleaseContextAtEndOfFrameHint(false);

#ifdef INIT_ONCE
}
#endif

}

void EngineOSG::draw() {
	viewer->setDone(false);
	viewer->setUpThreading();
	do {
		viewer->frame();
	} while (!viewer->done());

}

void EngineOSG::shutdown() {
	// avoid circular references
	viewer->getCamera()->setFinalDrawCallback(NULL);
	if (!offScreen) {
		osgViewer::View::EventHandlers eventHandlers = viewer->getEventHandlers();
		eventHandlers.clear();
	}
}
