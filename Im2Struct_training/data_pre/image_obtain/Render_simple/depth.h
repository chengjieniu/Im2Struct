#ifndef __depth__
#define __depth__
#include <windows.h>

#pragma comment(lib, "opengl32")
#pragma comment(lib, "glu32")

#include <gl/GL.h>
#include <cstdio>
void getRenderedImage(GLubyte *image, int gWidth , int gHeight, unsigned char *imageOutput);
void CopyAndModifyDepth(GLfloat *depth, int gWidth , int gHeight, double *imgDepth);
void getDepthOutput(double *imgDepth, int gWidth , int gHeight, double *depthOutput);
void WriteDepthFile(const char *filename, double *imgDepth, int gWidth , int gHeight);


class Depth {

public:
	Depth();
	~Depth();

};
#endif // __depth__
