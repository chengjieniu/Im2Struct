#include "depth.h"
#include "util.h"
#include <cstdlib>



void getRenderedImage(GLubyte *image, int gWidth , int gHeight, GLubyte *imageOutput)
{
	if (NULL == imageOutput) {
		return;
	}

	// OpenGL images are bottom to top.  Have to reverse. Plus, Matlab matrices are transposed
	for (int i = 0;i < gHeight;i++) {
		GLubyte *rowPtr2 = image + (gHeight - 1 - i) * gWidth * 3;
		for (int w = 0;w < gWidth;w++) {
			// red
			imageOutput[w*gHeight+i] = rowPtr2[w*3];
			// green
			imageOutput[gHeight*gWidth+w*gHeight+i] = rowPtr2[w*3+1];
			// blue
			imageOutput[gHeight*gWidth*2+w*gHeight+i] = rowPtr2[w*3+2];
		}
	}
}



void printDebugGetDepthOutput(GLfloat *depth, int gWidth , int gHeight)
{
	if (DEBUG) {
		GLfloat max = -1;
		GLfloat min = 1;
		for (int i = 0;i < gHeight*gWidth;i++) {
			double d = 1 - depth[i];
			if (d > max && d != 1) {
				max = d;
			}
			if (d < min && d != 0) {
				min = d;
			}
		}

		sout << "max,min: " << max << ", " << min << endl;
	}

}

void CopyAndModifyDepth(GLfloat *depth, int gWidth , int gHeight, double *imgDepth)
{
	printDebugGetDepthOutput(depth, gWidth , gHeight);

	//reverse depth color
	for (int i = 0;i < gWidth*gHeight;i++) {
		imgDepth[i] = 1 - depth[i];
	}
	/*fix: if scaling, scale imgDepth, not depth
	  if (min > 0) {
		float scale = 0.99 / (max - min + 0.01);
		for (i = 0;i < gHeight*gWidth;i++) {
			if (depth[i] > 0 && depth[i] < 1) {
				depth[i] -= (min - 0.01);
				depth[i] *= scale;
			}
		}
	}*/
}

void getDepthOutput(double *imgDepth, int gWidth , int gHeight, double *depthOutput)
{
	if (depthOutput != NULL) {
		transposeAndFlipY(imgDepth, gHeight, gWidth, depthOutput);
	}
}

void flipY(double *in, int m, int n, GLubyte  *out)
{
	for (int i = 0;i < m;i++) {
		for (int j = 0;j < n;j++) {
			out[i*n+j] = (GLubyte)in[(m-1-i)*n+j];
		}
	}
}

void printDebugWriteDepthFile(int gWidth , int gHeight, GLubyte *newd, int MAX)
{
	if (DEBUG) {
		int max = -1;
		int min = MAX + 1;
		for (int i = 0;i < gHeight*gWidth;i++) {
			if (newd[i] > max && newd[i] != MAX) {
				max = newd[i];
			}
			if (newd[i] < min && newd[i] != 0) {
				min = newd[i];
			}
		}
		sout << "new max,min: " << max << ", " << min << endl;
	}
}


void WriteDepthFile(const char *filename, double *imgDepth, int gWidth , int gHeight)
{
	FILE *f;

	f = fopen(filename, "w");
	if (!f) {
		printf("Couldn't open image file: %s\n", filename);
		return;
	}
	int MAX = 255;
	fprintf(f, "P5\n");
	fprintf(f, "# pgm-file created by %s\n", "renderer");
	fprintf(f, "%i %i\n", gWidth, gHeight);
	fprintf(f, "255\n");
	fclose(f);
	f = fopen(filename, "ab");     /* now append binary data */
	if (!f) {
		printf("Couldn't append to image file: %s\n", filename);
		return;
	}

	GLubyte *newd = (GLubyte *) malloc(gWidth * gHeight * sizeof(GLubyte));
	for (int i = 0;i < gHeight*gWidth;i++) {
		imgDepth[i] *= MAX;
	}
	flipY(imgDepth, gWidth, gHeight, newd);

	printDebugWriteDepthFile(gWidth, gHeight, newd, MAX);

	fwrite(newd, sizeof(GLubyte), gWidth*gHeight, f);

	fclose(f);

	if (DEBUG) {
	sout << "Wrote " << gWidth << " by " << gHeight << " image file: " << filename << endl;
	}
	free(newd);

}



Depth::Depth()
{
}

Depth::~Depth()
{
}

