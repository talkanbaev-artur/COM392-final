/******************************************************************************
*
*   HEADER INFO GOES HERE
*
/******************************************************************************/

#include "animate.h"

/******************************************************************************/
__global__ void drawGray(unsigned char* optr, const float* outSrc) {
  // map from threadIdx/BlockIdx to pixel position
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;
  int offset = x + y * blockDim.x * gridDim.x;

  float val = outSrc[offset];

  val = (val / 50.0) + 0.5; //get {-25 to 25} range into {0 to 1} range
  if (val < 0) val = 0;
  if (val > 1) val = 1;

  optr[offset * 4 + 0] = 255 * val;       // red
  optr[offset * 4 + 1] = 255 * val;       // green
  optr[offset * 4 + 2] = 255 * val;       // blue
  optr[offset * 4 + 3] = 255;             // alpha (opacity)
}

/******************************************************************************/
__global__ void drawColor(unsigned char* optr,
                          const float* red,
                          const float* green,
                          const float* blue) {
  // map from threadIdx/BlockIdx to pixel position
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;
  int offset = x + y * blockDim.x * gridDim.x;

  float theRed = red[offset];
//  theRed = (theRed / 50.0) + 0.5;
  if (theRed < 0) theRed = 0;
  if (theRed > 1) theRed = 1;

  float theGreen = green[offset];
//  theGreen = (theGreen / 50.0) + 0.5;
  if (theGreen < 0) theGreen = 0;
  if (theGreen > 1) theGreen = 1;

  float theBlue = blue[offset];
//  theBlue = (theBlue / 50.0) + 0.5;
  if (theBlue < 0) theBlue = 0;
  if (theBlue > 1) theBlue = 1;


  optr[offset * 4 + 0] = 255 * theRed;    // red
  optr[offset * 4 + 1] = 255 * theGreen;  // green
  optr[offset * 4 + 2] = 255 * theBlue;   // blue
  optr[offset * 4 + 3] = 255;             // alpha (opacity)
}

/******************************************************************************/
void CPUAnimBitmap::drawPalette(int width, int height) { // 32, SIZE/32

  int TPB = 32; // as defined in gpuCode.cu initGPU
  dim3 threads(TPB, TPB);
//  dim3 blocks(DIM / TPB, DIM / TPB);
  dim3 blocks(height / TPB, width / TPB);

//  drawGray <<< blocks, threads >>> (dev_bitmap, thePalette->gray);
  drawColor <<< blocks, threads >>> (dev_bitmap,
                                     thePalette->red,
                                     thePalette->green,
                                     thePalette->blue);


  // copy bitmap from device to host to draw frame:
  cudaMemcpy(get_ptr(), dev_bitmap, image_size(), cudaMemcpyDeviceToHost);
  glutMainLoopEvent();
  glutPostRedisplay();
}


/******************************************************************************/
CPUAnimBitmap::CPUAnimBitmap(int w, int h, GPU_Palette* d) {//void* d) {
  width = w;
  height = h;
  pixels = new unsigned char[width * height * 4];
//  dataBlock = d;
  thePalette = d;
  //clickDrag = NULL;
}

/******************************************************************************/
CPUAnimBitmap::~CPUAnimBitmap() {
  delete[] pixels;
}

/******************************************************************************/
void CPUAnimBitmap::click_drag(void (* f)(void*, int, int, int, int)) {
  clickDrag = f;
}

/******************************************************************************/
CPUAnimBitmap** CPUAnimBitmap::get_bitmap_ptr(void) {
  static CPUAnimBitmap* gBitmap;
  return &gBitmap;
}

/******************************************************************************/
void CPUAnimBitmap::mouse_func(int button, int state, int mx, int my) {
  if (button == GLUT_LEFT_BUTTON) {
    CPUAnimBitmap* bitmap = *(get_bitmap_ptr());
    if (state == GLUT_DOWN) {
      bitmap->dragStartX = mx;
      bitmap->dragStartY = my;
    } else if (state == GLUT_UP) {
      bitmap->clickDrag(bitmap->thePalette,
                        bitmap->dragStartX,
                        bitmap->dragStartY,
                        mx, my);
    }
  }
}

/******************************************************************************/
void CPUAnimBitmap::Draw(void) {
  CPUAnimBitmap* bitmap = *(get_bitmap_ptr());
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  glDrawPixels(bitmap->width, bitmap->height, GL_RGBA, GL_UNSIGNED_BYTE,
               bitmap->pixels);
  glutSwapBuffers();
}

/******************************************************************************/
void CPUAnimBitmap::initAnimation() {
  CPUAnimBitmap** bitmap = get_bitmap_ptr();
  *bitmap = this;
  int c = 1;
  char* dummy = "";
  glutInit(&c, &dummy);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
  glutInitWindowSize(width, height);
  glutCreateWindow("DNF");
  // glutKeyboardFunc(Key);
  glutDisplayFunc(Draw);
  if (clickDrag != NULL) glutMouseFunc(mouse_func);
}

/******************************************************************************/
__device__ unsigned char value(float n1, float n2, int hue) {
  if (hue > 360) hue -= 360;
  else if (hue < 0) hue += 360;

  if (hue < 60)
    return (unsigned char) (255 * (n1 + (n2 - n1) * hue / 60));
  if (hue < 180)
    return (unsigned char) (255 * n2);
  if (hue < 240)
    return (unsigned char) (255 * (n1 + (n2 - n1) * (240 - hue) / 60));
  return (unsigned char) (255 * n1);
}

/******************************************************************************/
