#include "mex.h"

/* function w = missXtu(X,u,not_miss,J) */

void missXtuDouble(double *w, 
double *X, double *u, double *not_miss, 
mwSize I, mwSize J)
{
	int i, j, idx;
	double ww, norm_sq, ui;
	for (j=0; j<J; j++) {
		ww = 0.;
		norm_sq = 0.;
		for (i=0; i<I; i++)
		{
			idx = i + j*I;
			ui = u[i];
			if (not_miss[idx]) {
				ww += X[idx]*ui;
				norm_sq += ui*ui;
			}
		}
		if (norm_sq != 0.0)
		{
			ww /= norm_sq;
		}
		w[j] = ww;
	}
}

void missXtuLogical(double *w, 
double *X, double *u, mxLogical *not_miss, 
mwSize I, mwSize J)
{
	int i, j, idx;
	double ww, norm_sq, ui;
	for (j=0; j<J; j++) {
		ww = 0.;
		norm_sq = 0.;
		for (i=0; i<I; i++)
		{
			idx = i + j*I;
			ui = u[i];
			if (not_miss[idx]) {
				ww += X[idx]*ui;
				norm_sq += ui*ui;
			}
		}
		if (norm_sq != 0.0)
		{
			ww /= norm_sq;
		}
		w[j] = ww;
	}
}

void mexFunction(int nlhs, mxArray *plhs[],
const int nrhs, const mxArray *prhs[])
{
	const mxArray *X_m, *u_m, *not_miss_m;
	mxArray *w_m;
	double *X, *u, *not_miss_double, *w;
    mxLogical *not_miss_logical;
	mwSize I, J;
    char msg[100];
    
    /* Check for proper number of input and output arguments */
    if (nrhs != 4) {
        mexErrMsgTxt("Four input argument required.");
    }
    if (nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }

	/* More readable names */
	X_m = prhs[0];
	u_m = prhs[1];
	not_miss_m = prhs[2];
    
    /* Check data type of first two input arguments */
    if ( !(mxIsDouble(X_m) && mxIsDouble(u_m)) ) {
        mexErrMsgTxt("Input arrays must be of type double.");
    }
    
    /* Check that inputs are 2D arrays */
    if ( mxGetNumberOfDimensions(X_m) != 2 ||
    mxGetNumberOfDimensions(u_m) != 2 ) {
        mexErrMsgTxt("Input arrays must be 2D.");
    }
    
    /* Check that inputs are correctly sized.*/
    I = mxGetM(X_m);
    J = mxGetN(X_m);

	if (mxGetM(u_m) != I || mxGetN(u_m) != 1) {
		mexErrMsgTxt("Inconsistent array size.");
	}
	
	if (mxGetM(not_miss_m) != I || mxGetN(not_miss_m) != J) {
		mexErrMsgTxt("Inconsistent size for missing value array.");
	}
	
	/* Create output */
	w_m = mxCreateDoubleMatrix(J,1,mxREAL);
	plhs[0] = w_m;
	
	/* Get real data */
	X = mxGetPr(X_m);
	u = mxGetPr(u_m);
	w = mxGetPr(w_m);

    /* Check data type of third argument */
    if ( mxIsDouble(not_miss_m) ) {
    	not_miss_double = mxGetPr(not_miss_m);
        /* Calculate product */
        missXtuDouble(w, X,u,not_miss_double, I,J);
    }
    else if ( mxIsLogical(not_miss_m) ) {
    	not_miss_logical = mxGetLogicals(not_miss_m);
        /* Calculate product */
        missXtuLogical(w, X,u,not_miss_logical, I,J);
    }
    else {
        mexErrMsgTxt("Missing data array must be double or logical");
    }

}
