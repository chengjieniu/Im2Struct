#include <windows.h>
#include <iostream>
#include <sstream>
#include <mex.h>

#include "util.h"
#include "Engine.h"
#include "EngineOSG.h"

using namespace std;

const bool SPEED = true;

const string programName = "renderer";
enum MatlabInEnum {
	MATLAB_IN_WIDTH = 0,
	MATLAB_IN_HEIGHT,
	MATLAB_IN_FILENAME,
	MATLAB_IN_WRITEFILES,
	MATLAB_IN_LIGHTING,
	MATLAB_IN_DISTANCE,
	MATLAB_IN_A = MATLAB_IN_DISTANCE,
	MATLAB_IN_ELEVATION,
	MATLAB_IN_R = MATLAB_IN_ELEVATION,
	MATLAB_IN_AZIMUTH,
	MATLAB_IN_T = MATLAB_IN_AZIMUTH,
	MATLAB_IN_YAW,
	MATLAB_IN_DEG_ORDER,
	MATLAB_IN_VERTICES,
	MATLAB_IN_COLORS,
	MATLAB_IN_COLORS_BINDING,
	MATLAB_IN_NORMALS,
	MATLAB_IN_NORMALS_BINDING
};
enum MatlabOutEnum {
	MATLAB_OUT_DEPTH_IMAGE = 0,
	MATLAB_OUT_RENDERED_IMAGE,
	MATLAB_OUT_UNPROJECT,
	MATLAB_OUT_A,
	MATLAB_OUT_R,
	MATLAB_OUT_T,
	MATLAB_OUT_VERTICES,
	MATLAB_OUT_COLORS,
	MATLAB_OUT_COLORS_BINDING,
	MATLAB_OUT_NORMALS,
	MATLAB_OUT_NORMALS_BINDING
};

void run(int width, int height, double *depthOutput, unsigned char * imageOutput, string filename,
		double distance, double elevation, double azimuth, double yaw, bool sphereOrientation,
		double *A, double *R, double *T, double *unprojectOutput, MeshData &meshData,
		bool writeFiles, bool offScreen, double *AOutput, double *ROutput, double *TOutput,
		bool lighting, double distanceInc, string deg_order, bool getUnproject) {
	
	Engine *engine = new EngineOSG;
	engine->setParams(width, height, depthOutput, imageOutput, filename, distance, elevation,
			azimuth, yaw, sphereOrientation, A, R, T, unprojectOutput, meshData, writeFiles,
			offScreen, AOutput, ROutput, TOutput, lighting, distanceInc, deg_order, getUnproject);
	engine->init();

	try {
		if (meshData.getVertices().empty()) {
			engine->initDataFromFile();
		} else {
			engine->initData();
		}
		meshData.copy(engine->getMeshData());
		engine->initCamera();

		engine->initCanvas();
		engine->draw();
	} catch (char const *e) {
		engine->shutdown();
		delete engine;
		throw e;
	}
	engine->shutdown();
	delete engine;
}

int main(int argc, const char* argv[]) {
	string filename;
	double distanceInc = 1;
	string deg_order = "zxy";
	if (argc > 1) {
		filename = argv[1];
		if (argc > 2) {
			deg_order = argv[2];
			if (argc > 3) {
				distanceInc = atoi(argv[3]);
			}
		}
	}
	double elevation = 0;
	double azimuth = 0;
	double yaw = 0;
	//30 degrees for Bulue
	double A[9] = { 770.455, 0, 250, 0, 963.068, 250, 0, 0, 1 };
	double R[9] = { 1, -8.76125e-06, -1.52317e-05, -4.66411e-08, 0.865505, -0.5009, 1.75716e-05,
			0.5009, 0.865505 };
	double T[3] = { -0.0175613, 0.000945255, 0.782925 };

	bool writeFiles = false;
	bool offScreen = false;
	bool lighting = false;
	bool getUnproject = false;
	double AOutput[9];
	try {
		{
			sout.str("");
			MeshData meshData;

			run(500, 500, NULL, NULL, filename, 0, osg::DegreesToRadians(elevation),
					osg::DegreesToRadians(azimuth), osg::DegreesToRadians(yaw), true, NULL, NULL,
					NULL, NULL, meshData, writeFiles, offScreen, AOutput, NULL, NULL, lighting,
					distanceInc, deg_order, getUnproject);
			printf("%s", sout.str().c_str());
		}
	} catch (char const *e) {
		//execution errors
		printf("%s", sout.str().c_str());
	}

	return 0;
}

void printUsage() {
	printf("%s usage:\n", programName.c_str());
	printf(
			"\t[depth_image, rendered_image, unproject, out_A, out_R, out_T]\n");
	printf(
			"\t= %s(width, height, filename, writefiles, lighting, sphere orientation (5 arguments)/camera orientation (3 arguments))\n",
			programName.c_str());
	printf("Most input and output parameters are optional.\n");
	printf("width and height should be unsigned integers.\n");
	printf(
			"filename - the input mesh filename.\n");
	printf("writefiles can be 0 (disabled, the default) or 1 (outputs depth image: depth.pgm and the rendered image: rendered.png).\n");
	printf("\tPreferably it should be disabled (0) and the output depth and rendered parameters can be further processed by MATLAB.\n");
	printf("lighting should be 0 (disabled, the default) or 1 (enabled).\n");
	printf(
			"sphere orientation are the following 5 arguments: distance, elevation, azimuth, yaw and degree order.\n");
	printf(
			"\tdistance - a number added to the (auto calculated) model's bounding sphere radius. 0 is usually suitable.\n");
	printf(
			"\televation, azimuth and yaw are degrees. The camera position on the bounding sphere is specified using them.\n");
	printf(
			"\tdegree order - a string specifying the order, e.g. 'xyz, 'zxy' etc.\n");
	printf(
			"camera orientation are 3 arguments: A (intrinsic matrix), R and T (extrinsic)\n");
	printf("\n\nExamples:\n");
	printf("%s(300,300,'example.wrl');\n", programName.c_str());
	printf("\tPerforms the rendering. However, since no output parameters were passed nothing is returned.\n");
	printf("%s(300,300,'example.wrl',1);\n", programName.c_str());
	printf("\tPerforms the rendering and writes data files (depth.pgm and rendered.png). Note that this is _not_ the preferred way of usage.\n");
	printf("[depth, rendered]=%s(300, 300, 'example.wrl');\n", programName.c_str());
	printf("\tReturns the depth matrix and rendered image to MATLAB. No output files are written. This is the preferred usage.\n");
	printf("figure, imshow(depth); figure, imshow(rendered);\n");
	printf("\tDisplays the results.\n");
	printf(
			"[depth, rendered, unproject, A, R, T]=%s(300, 300, 'example.wrl');\n",
			programName.c_str());
	printf("\tAlso returns the camera matrices - A,R and T as well as the unprojection matrix.\n");
	printf("\tNow 'unproject(125,149,1:3)' returns the world XYZ coordinate of the image point (x=148,y=124)\n");
	printf("[depth, rendered, unproject, A, R, T]=%s(300, 300, 'example.wrl',0,0,0.5,10,20,30,'zxy');\n", programName.c_str());
	printf("\tRenders the mesh with a distance of 0.5, an elevation of 10 degrees, azimuth of 20 degrees and yaw of 30 degrees.\n"); 
	printf("[depth, rendered, unproject]=%s(300, 300, 'example.wrl',0,0,A,R,T);\n", programName.c_str());
	printf("\tProviding the camera matrices returned from the previous example will yield the same results.\n"); 
	printf("Animation example:\n");
	printf("\tfor yaw=0:10:360\n");
	printf("\t\t[~, rendered]=renderer(300, 300, 'example.wrl',0,0,0.5,10,20,yaw,'zxy'); \n");
	printf("\t\tfigure(1); imshow(rendered); pause;\n");
	printf("\tend;\n");
	printf("\tRotate in-plane by varying the yaw parameter. Each pressed key shows another frame of the animation.\n");

}

void hintForHelp() {
	int err = 1;
	printf("Use %s without arguments for help.\n", programName.c_str());
	throw err;

}

void checkValid(MatlabInEnum in, const mxArray*prhs[]) {
	bool ok = true;
	switch (in) {
	case MATLAB_IN_WIDTH:
	case MATLAB_IN_HEIGHT:
		if ((mxIsNumeric(prhs[in]) && ((unsigned int) mxGetScalar(prhs[in])
				!= mxGetScalar(prhs[in]))) || !mxIsNumeric(prhs[in])) {
			// check for unsigned integer
			printf("width and height should be unsigned integers.\n\n");
			ok = false;
		}
		break;
	case MATLAB_IN_FILENAME:
		if (!mxIsChar(prhs[in])) {
			printf("filename should be a string.\n\n");
			ok = false;
		}
		break;
	case MATLAB_IN_WRITEFILES:
		if ((mxIsNumeric(prhs[in]) && mxGetScalar(prhs[in]) != 0 && mxGetScalar(prhs[in]) != 1)
				|| !mxIsNumeric(prhs[in])) {
			printf("writefiles should be 0 or 1.\n\n");
			ok = false;
		}
		break;
	case MATLAB_IN_LIGHTING:
		if ((mxIsNumeric(prhs[in]) && mxGetScalar(prhs[in]) != 0 && mxGetScalar(prhs[in]) != 1)
				|| !mxIsNumeric(prhs[in])) {
			printf("lighting should be 0 or 1.\n\n");
			ok = false;
		}
		break;

	case MATLAB_IN_VERTICES:
		//            printf("%s\n", mxGetClassName(prhs[in]));
		if (mxGetN(prhs[in]) != TRIPLET) {
			printf("in_vertices should be an M x 3 matrix with real values.\n\n");
			ok = false;
		}
		break;
	case MATLAB_IN_COLORS:
		if (mxGetN(prhs[in]) != QUADLET) {
			printf(
					"in_colors should be an M x 4 matrix with real values. Not necessarily the same M of as of in_vertices.\n\n");
			ok = false;
		}
		break;
	case MATLAB_IN_NORMALS:
		if (mxGetN(prhs[in]) != TRIPLET) {
			printf(
					"in_normals should be an M x 3 matrix with real values. Not necessarily the same M as of in_vertices.\n\n");
			ok = false;
		}
		break;
	default:
		break;
	}
	if (!ok) {
		hintForHelp();
	}
}

string extractString(MatlabInEnum matlabInEnum, const mxArray*prhs[]) {
	string result;
	char *buf;
	int buflen;
	int status;
	buflen = mxGetN(prhs[matlabInEnum]) * sizeof(mxChar) + 1;
	buf = (char*) mxMalloc(buflen);
	status = mxGetString(prhs[matlabInEnum], buf, buflen);
	result = buf;
	mxFree(buf);
	return result;
}

void checkValidSphereOrientation(int nrhs, const mxArray*prhs[], double &distance,
		double &elevation, double &azimuth, double &yaw, string &deg_order) {
	bool ok = true;

	if (!(nrhs > MATLAB_IN_DEG_ORDER)) {
		printf(
				"when specifying orientation by a sphere, must specify all 5 parameters: distance, elevation , azimuth, yaw and degree order.\n\n");
		ok = false;
	} else if (!mxIsNumeric(prhs[MATLAB_IN_DISTANCE])) {
		printf("distance should be a number.\n\n");
		ok = false;
	} else if (!mxIsNumeric(prhs[MATLAB_IN_ELEVATION])) {
		printf("elevation should be a number.\n\n");
		ok = false;
	} else if (!mxIsNumeric(prhs[MATLAB_IN_AZIMUTH])) {
		printf("azimuth should be a number.\n\n");
		ok = false;
	} else if (!mxIsNumeric(prhs[MATLAB_IN_YAW])) {
		printf("yaw should be a number.\n\n");
		ok = false;
	} else if (!mxIsChar(prhs[MATLAB_IN_DEG_ORDER])) {
		printf("degree order should be a string: xyz/zyx/xzy/zxy.\n\n");
		ok = false;
	}

	if (!ok) {
		hintForHelp();
	}

	distance = mxGetScalar(prhs[MATLAB_IN_DISTANCE]);
	elevation = osg::DegreesToRadians(mxGetScalar(prhs[MATLAB_IN_ELEVATION]));
	azimuth = osg::DegreesToRadians(mxGetScalar(prhs[MATLAB_IN_AZIMUTH]));
	yaw = osg::DegreesToRadians(mxGetScalar(prhs[MATLAB_IN_YAW]));
	deg_order = extractString(MATLAB_IN_DEG_ORDER, prhs);
}

void checkValidMatrixOrientation(int nrhs, const mxArray*prhs[], double *A, double *R, double *&T) {
	bool ok = true;

	if (!(nrhs > MATLAB_IN_T)) {
		printf(
				"when specifying orientation by a matrix, must specify all 3 parameters: A, R and T.\n\n");
		ok = false;
	} else if (mxGetN(prhs[MATLAB_IN_A]) != TRIPLET || mxGetM(prhs[MATLAB_IN_A]) != TRIPLET) {
		printf("A should be an 3 x 3 matrix with real values.\n\n");
		ok = false;
	} else if (mxGetN(prhs[MATLAB_IN_R]) != TRIPLET || mxGetM(prhs[MATLAB_IN_R]) != TRIPLET) {
		printf("R should be an 3 x 3 matrix with real values.\n\n");
		ok = false;
	} else if (mxGetN(prhs[MATLAB_IN_T]) != TRIPLET) {
		printf("T should be an 1 x 3 vector with real values.\n\n");
		ok = false;
	}
	if (!ok) {
		hintForHelp();
	}

	// Matlab matrix is transposed
	transpose(mxGetPr(prhs[MATLAB_IN_A]), TRIPLET, TRIPLET, A);
	transpose(mxGetPr(prhs[MATLAB_IN_R]), TRIPLET, TRIPLET, R);
	T = mxGetPr(prhs[MATLAB_IN_T]);

}

//convert mesh data from Matlab
vector<GLfloat> handleMeshInput(const mxArray*prhs[], MatlabInEnum in) {
	vector<GLfloat> out;
	checkValid(in, prhs);
	int m = mxGetM(prhs[in]);
	int n = mxGetN(prhs[in]);
	double *matIn = mxGetPr(prhs[in]);
	if (SPEED) {
		for (int i = 0; i < m; i++) {
			for (int j = 0; j < n; j++) {
				out.push_back(matIn[j * m + i]);
			}
		}
	} else {
		double *temp = new double[m * n];
		transpose(matIn, m, n, temp);
		for (int i = 0; i < m * n; i++) {
			out.push_back(temp[i]);
		}
		delete temp;
	}
	return out;
}

//convert mesh data to Matlab
void handleMeshOutput(mxArray *plhs[], MatlabOutEnum out, vector<GLfloat> vec, int m) {
	int n = vec.size() / m;
	// n*m matrix of double values
	plhs[out] = mxCreateDoubleMatrix(n, m, mxREAL);
	double *matOutput = mxGetPr(plhs[out]);
	int i = 0;
	for (vector<GLfloat>::const_iterator vi = vec.begin(); vi != vec.end();) {
		for (int j = 0; j < m; j++) {
			// Matlab matrix is transposed
			matOutput[j * n + i] = *vi++;
		}
		i++;
	}

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[]) {
	try {
		sout.str("");
		if (nrhs <= MATLAB_IN_FILENAME) {
			printUsage();
			throw 1;
		}

		sout << endl << programName << " start:" << endl;

		// input
		unsigned int width = 0;
		unsigned int height = 0;

		if (nrhs > MATLAB_IN_WIDTH) {
			checkValid(MATLAB_IN_WIDTH, prhs);
			width = (unsigned int) mxGetScalar(prhs[MATLAB_IN_WIDTH]);
		}
		if (nrhs > MATLAB_IN_HEIGHT) {
			checkValid(MATLAB_IN_HEIGHT, prhs);
			height = (unsigned int) mxGetScalar(prhs[MATLAB_IN_HEIGHT]);
		}
		string filename;
		if (nrhs > MATLAB_IN_FILENAME) {
			checkValid(MATLAB_IN_FILENAME, prhs);
			filename = extractString(MATLAB_IN_FILENAME, prhs);
		}
		bool writeFiles = false;
		if (nrhs > MATLAB_IN_WRITEFILES) {
			checkValid(MATLAB_IN_WRITEFILES, prhs);
			writeFiles = (mxGetScalar(prhs[MATLAB_IN_WRITEFILES]) == 1);
		}
		bool lighting = false;
		if (nrhs > MATLAB_IN_LIGHTING) {
			checkValid(MATLAB_IN_LIGHTING, prhs);
			lighting = (mxGetScalar(prhs[MATLAB_IN_LIGHTING]) == 1);
		}

		double distance = 0;
		double elevation = 0;
		double azimuth = 0;
		double yaw = 0;
		double A[TRIPLET * TRIPLET];
		double R[TRIPLET * TRIPLET];
		double *T = NULL;
		bool sphereOrientation = true;
		string deg_order;
		if (nrhs > MATLAB_IN_DISTANCE) {
			sphereOrientation = (1 == mxGetN(prhs[MATLAB_IN_DISTANCE])) && (1 == mxGetM(
					prhs[MATLAB_IN_DISTANCE]));
			if (sphereOrientation) {
				checkValidSphereOrientation(nrhs, prhs, distance, elevation, azimuth, yaw,
						deg_order);
			} else {
				checkValidMatrixOrientation(nrhs, prhs, A, R, T);
			}
		}

		vector<GLfloat> verticesInput;
		vector<GLfloat> colorsInput;
		vector<GLfloat> normalsInput;
		int cbind;
		int nbind;
		if (nrhs > MATLAB_IN_VERTICES) {
			verticesInput = handleMeshInput(prhs, MATLAB_IN_VERTICES);
		}

		if (nrhs > MATLAB_IN_COLORS) {
			colorsInput = handleMeshInput(prhs, MATLAB_IN_COLORS);
		}
		if (nrhs > MATLAB_IN_COLORS_BINDING) {
			cbind = (int) mxGetScalar(prhs[MATLAB_IN_COLORS_BINDING]);
		}
		if (nrhs > MATLAB_IN_NORMALS) {
			normalsInput = handleMeshInput(prhs, MATLAB_IN_NORMALS);
		}
		if (nrhs > MATLAB_IN_NORMALS_BINDING) {
			nbind = (int) mxGetScalar(prhs[MATLAB_IN_NORMALS_BINDING]);
		}

		// output


		double *depthOutput = NULL;
		unsigned char *imageOutput = NULL;
		double *unprojectOutput = NULL;
		if (nlhs > MATLAB_OUT_DEPTH_IMAGE) {
			plhs[MATLAB_OUT_DEPTH_IMAGE] = mxCreateDoubleMatrix(height, width, mxREAL);
			depthOutput = mxGetPr(plhs[MATLAB_OUT_DEPTH_IMAGE]);
		}
		if (nlhs > MATLAB_OUT_RENDERED_IMAGE) {
			const mwSize dims[] = { height, width, 3 };
			plhs[MATLAB_OUT_RENDERED_IMAGE] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
			imageOutput = (GLubyte*) mxGetPr(plhs[MATLAB_OUT_RENDERED_IMAGE]);
		}
		if (nlhs > MATLAB_OUT_UNPROJECT) {
			const mwSize dims[] = { height, width, 3 };
			plhs[MATLAB_OUT_UNPROJECT] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
			unprojectOutput = (GLdouble*) mxGetPr(plhs[MATLAB_OUT_UNPROJECT]);
		}

		double *AOutput = NULL;
		if (nlhs > MATLAB_OUT_A) {
			plhs[MATLAB_OUT_A] = mxCreateDoubleMatrix(TRIPLET, TRIPLET, mxREAL);
			AOutput = mxGetPr(plhs[MATLAB_OUT_A]);
		}
		double *ROutput = NULL;
		if (nlhs > MATLAB_OUT_R) {
			plhs[MATLAB_OUT_R] = mxCreateDoubleMatrix(TRIPLET, TRIPLET, mxREAL);
			ROutput = mxGetPr(plhs[MATLAB_OUT_R]);
		}
		double *TOutput = NULL;
		if (nlhs > MATLAB_OUT_T) {
			plhs[MATLAB_OUT_T] = mxCreateDoubleMatrix(1, TRIPLET, mxREAL);
			TOutput = mxGetPr(plhs[MATLAB_OUT_T]);
		}

		MeshData meshData(verticesInput, colorsInput, cbind, normalsInput, nbind);
		run(width, height, depthOutput, imageOutput, filename, distance, elevation, azimuth, yaw,
				sphereOrientation, A, R, T, unprojectOutput, meshData, writeFiles, true, AOutput,
				ROutput, TOutput, lighting, 0, deg_order, unprojectOutput != NULL);

		// more output -- disable for now
		/* vector<GLfloat> vertices = meshData.getVertices();
		if (!vertices.empty()) {
			if (nlhs > MATLAB_OUT_VERTICES) {
				handleMeshOutput(plhs, MATLAB_OUT_VERTICES, vertices, TRIPLET);
			}

			if (nlhs > MATLAB_OUT_COLORS) {
				vector<GLfloat> colors = meshData.getColors();
				if (!colors.empty()) {
					handleMeshOutput(plhs, MATLAB_OUT_COLORS, colors, QUADLET);
					if (nlhs > MATLAB_OUT_COLORS_BINDING) {
						plhs[MATLAB_OUT_COLORS_BINDING] = mxCreateNumericMatrix(1, 1,
								mxUINT8_CLASS, mxREAL);
						unsigned char *cbindOutput = (unsigned char *) mxGetPr(
								plhs[MATLAB_OUT_COLORS_BINDING]);
						*cbindOutput = meshData.getCbind();
					}

				}
			}
			if (nlhs > MATLAB_OUT_NORMALS) {
				vector<GLfloat> normals = meshData.getNormals();
				handleMeshOutput(plhs, MATLAB_OUT_NORMALS, normals, TRIPLET);
				if (nlhs > MATLAB_OUT_NORMALS_BINDING) {
					plhs[MATLAB_OUT_NORMALS_BINDING] = mxCreateNumericMatrix(1, 1, mxUINT8_CLASS,
							mxREAL);
					unsigned char *nbindOutput = (unsigned char *) mxGetPr(
							plhs[MATLAB_OUT_NORMALS_BINDING]);
					*nbindOutput = meshData.getNbind();
				}
			}
		} else if (nlhs > MATLAB_OUT_VERTICES) {
			printf(
					"Error: vertices specified as output parameter, but the model is not a version 1.0 VRML model.\nOnly .wrl models are supported for output vertices. Other models are supported only for rendering and depth retrieval.\n");
		} */
		sout << endl << programName << " end." << endl;
		if (DEBUG) {
			printf("%s", sout.str().c_str());
		}
	} catch (const char *err) {
		//execution errors
		if (DEBUG) {
			printf("%s", sout.str().c_str());
		}
		mexErrMsgIdAndTxt((programName+":Err").c_str(), err);
	} catch (int err) {
		//validations errors
		if (DEBUG) {
			printf("%s", sout.str().c_str());
		}
		mexErrMsgIdAndTxt((programName+":Err").c_str(), "Please see the above message");
	}
}
