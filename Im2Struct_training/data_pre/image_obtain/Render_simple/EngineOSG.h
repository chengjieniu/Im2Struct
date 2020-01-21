#ifndef __engineosg__
#define __engineosg__

#include <osgViewer/Viewer>
#include "Engine.h"
#include <windows.h>

class EngineOSG : public Engine {
	osg::ref_ptr<osgViewer::Viewer> viewer;

	void drawFromFileAndData();
	void drawPoints(vector<GLfloat> &vertices);
	void setupSphereOrientation();
	void getIntrisnicMatrix();
public:
	EngineOSG();
	virtual ~EngineOSG();
	void init();
	void initDataFromFile();
	void initData();
	void initCamera();
	void initCanvas();
	void draw();
	void shutdown();
friend class CaptureCB;
friend class TextureCB;
friend class KeyboardEventHandler;
};
#endif // __engineosg__
