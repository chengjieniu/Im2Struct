#ifndef __engine__
#define __engine__

#include <vector>
#include <iostream>
#include <windows.h>
using namespace std;

const bool USE_CACHE = true;
//if enabled, the first specified resolution remains regardless of further resolutions
//#define INIT_ONCE


class MeshData {
	vector<float> vertices;
	vector<float> colors;
	vector<float> normals;
	int cbind;
	int nbind;

public:

	MeshData() {
	}

	MeshData(vector<float> _vertices, vector<float> _colors, int _cbind, vector<float> _normals,
			int _nbind) :
		vertices(_vertices), colors(_colors), normals(_normals), cbind(_cbind), nbind(_nbind) {
	}

	void copy(const MeshData &md) {
		vertices = md.vertices;
		colors = md.colors;
		normals = md.normals;
		cbind = md.cbind;
		nbind = md.nbind;
	}

	void clear() {
		vertices.clear();
		normals.clear();
		colors.clear();

	}
	void setCbind(const int& cbind) {
		this->cbind = cbind;
	}
	void setColors(const vector<float>& colors) {
		this->colors = colors;
	}
	void setNbind(const int& nbind) {
		this->nbind = nbind;
	}
	void setNormals(const vector<float>& normals) {
		this->normals = normals;
	}
	void setVertices(const vector<float>& vertices) {
		this->vertices = vertices;
	}
	const int& getCbind() const {
		return cbind;
	}
	const vector<float>& getColors() const {
		return colors;
	}
	const int& getNbind() const {
		return nbind;
	}
	const vector<float>& getNormals() const {
		return normals;
	}
	const vector<float>& getVertices() const {
		return vertices;
	}
};

class Engine {
protected:
	int width;
	int height;
	double *depthOutput;
	unsigned char *imageOutput;
	string filename;
	double distance;
	double elevation;
	double azimuth;
	double yaw;
	bool sphereOrientation;
	double *A;
	double *R;
	double *T;
	double *AOutput;
	double *ROutput;
	double *TOutput;
	double *unprojectOutput;
	MeshData meshData;
	bool writeFiles;
	bool lighting;
	bool offScreen;
	bool getUnproject;
	double distanceInc;
	string deg_order;
public:
	Engine();
	virtual ~Engine();

	void setParams(int width, int height, double *depthOutput, unsigned char *imageOutput,
			string filename, double distance, double elevation, double azimuth, double yaw,
			bool sphereOrientation, double *A, double *R, double *T, double *unprojectOutput,
			MeshData meshData, bool writeFiles, bool offScreen, double *AOutput, double *ROutput,
			double *TOutput, bool lighting,
					double distanceInc, string deg_order, bool getUnproject);

	const MeshData& getMeshData() const {
		return meshData;
	}

	virtual void init()=0;
	virtual void initDataFromFile()=0;
	virtual void initData()=0;
	virtual void initCamera()=0;
	virtual void initCanvas()=0;
	virtual void draw()=0;
	virtual void shutdown()=0;

};

#endif // __engine__
