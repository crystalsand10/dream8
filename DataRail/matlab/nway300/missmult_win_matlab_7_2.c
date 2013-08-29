#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[])
{
    /* mwSize */ int i, j, k, idx, ia, ib;
    /* mwSize */ int nnan=0, nz=0;
    /* mwSize */ int mx, nx, my, ny;
    const /* mwSize */ int *szX, *szY;
    double *pA, *pB, *pX, term;
    double a, b;
    int numReal;
    char msg[100];
    
    /* Check for proper number of input and output arguments */
    if (nrhs != 2) {
        mexErrMsgTxt("Two input argument required.");
    }
    if (nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of input argument */
    if (!(mxIsDouble(prhs[0]) && mxIsDouble(prhs[1]))) {
        mexErrMsgTxt("Input arrays must be of type double.");
    }
    
    /* Check that inputs are 2D arrays */
    if ( mxGetNumberOfDimensions(prhs[0]) != 2 ||
    mxGetNumberOfDimensions(prhs[1]) != 2 ) {
        mexErrMsgTxt("Input arrays must be 2D.");
    }
    
    /* Check that inputs are correctly sized.*/
    szX = mxGetDimensions(prhs[0]);
    szY = mxGetDimensions(prhs[1]);
    mx = szX[0];
    nx = szX[1];
    my = szY[0];
    ny = szY[1];
    if ( nx != my ) {
        mexErrMsgTxt("Inner matrix dimensions must agree.");
    }
    
    /* Get the data */
    pA=(double *)mxGetPr(prhs[0]);
    pB=(double *)mxGetPr(prhs[1]);
    
    /* Create result matrix */
    plhs[0]=mxCreateDoubleMatrix(mx,ny,mxREAL);
    pX=mxGetPr(plhs[0]);
    
    for(i=0; i<mx; i++) {
        for(j=0; j<ny; j++) {
            term = 0;
            numReal = 0;
            for(k=0; k<nx; k++) {
                ia = i+k*mx;
                ib = j*my+k;
                a = pA[ia];
                b = pB[ib];
/* sprintf(msg, "test (%d=%f),(%d=%f)\n", ia, a, ib, b);
 mexWarnMsgTxt(msg); */
                if ( !(mxIsNaN(a) ||
                mxIsNaN(b)) ) {
                    /* both real */
                    term += a*b;
                    numReal += 1;
                }
            } /* k */
            idx = i+j*mx;
            if (numReal == nx) {
                pX[idx] = term;
            } else {
                pX[idx] = term*nx/numReal;
            }
        } /* j */
    } /* i */
    
/*    //     for(j=0;j<elements;j++){
    //         if( pA[j]==0) {
    //             nz++;
    //         }
    //         if( mxIsNaN(pr[j]) ){
    //             nnan++;
    //         }
    //     } */
}
