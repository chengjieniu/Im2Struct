#include "Engine.h"
Engine::Engine() {
}

Engine::~Engine() {
}

void Engine::setParams(int width, int height, double *depthOutput, unsigned char *imageOutput,
		string filename, double distance, double elevation, double azimuth, double yaw,
		bool sphereOrientation, double *A, double *R, double *T, double *unprojectOutput,
		MeshData meshData, bool writeFiles, bool offScreen, double *AOutput, double *ROutput,
		double *TOutput, bool lighting, double distanceInc, string deg_order, bool getUnproject) {
	this->width = width;
	this->height = height;
	this->depthOutput = depthOutput;
	this->imageOutput = imageOutput;
	this->filename = filename;
	this->distance = distance;
	this->elevation = elevation;
	this->azimuth = azimuth;
	this->yaw = yaw;
	this->sphereOrientation = sphereOrientation;
	this->A = A;
	this->R = R;
	this->T = T;
	this->unprojectOutput = unprojectOutput;
	this->meshData = meshData;
	this->writeFiles = writeFiles;
	this->offScreen = offScreen;
	this->AOutput = AOutput;
	this->ROutput = ROutput;
	this->TOutput = TOutput;
	this->lighting = lighting;
	this->distanceInc = distanceInc;
	this->deg_order = deg_order;
	this->getUnproject = getUnproject;
}
