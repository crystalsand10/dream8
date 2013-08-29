#include "mex.h"
#include "math.h"

#define NARGIN 3
#define FNAME "pcanipals.m"
/* function [t,p,Mean] = pcanipals(X,F,cent) */

#define FIT_CRIT 1.e-7
#define MAX_IT 1000

void pcanipals(double *t, double *p, double *Mean,
	double *T, double *P,
	double *X, const int F,
	const bool *isnanX, const bool cent, const int I, const int J);

void mexFunction(int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[])
{
	const mxArray *Xorig_m, *F_m, *cent_m;
	mxArray *X_m, *t_m, *p_m, *Mean_m;
	double *t, *p, *Mean, *X;
	mxArray *T_m, *P_m;
	double *T, *P;
	
	int F;
	bool cent;
	
	mxArray *isnanX_m;
	mxLogical *isnanX;
	int i, i1;
	const mwSize *sz;
	char msg[256];
	int I, J;
		
	if (nrhs != NARGIN) {
		mexErrMsgTxt("Three inputs required -- see " FNAME);
	}
	
	for (i=0; i<NARGIN; i++)
	{
		i1 = i+1;
		/* Check data type of input arguments */
	    if (!mxIsDouble(prhs[i])) {
			sprintf(msg, "Input %d must be numeric -- see " FNAME, i1);
	        mxErrMsgTxt(msg);
		}
    	/* Check that all inputs are 2D arrays */
		if (mxGetNumberOfDimensions(prhs[i]) != 2) {
			sprintf(msg, "Input %d cannot have more than 2 dimensions -- see " FNAME, i1);
	        mxErrMsgTxt(msg);
		}
		/* Check scalar arguments */
		switch (i) {
			case 1:
			case 2:
				sz = mxGetDimensions(prhs[i]);
				if (sz[0] != 1 || sz[1] != 1) {
					sprintf(msg, "Input %d must be a scalar -- see " FNAME, i1);
			        mxErrMsgTxt(msg);
				}
		}
    }

	/* User-friendly argument names */
	Xorig_m = prhs[0];
	F_m = prhs[1];
	cent_m = prhs[2];
	/* Work with a copy of X so I can change the values, if necessary */
	X_m = mxDuplicateArray(Xorig_m);
	X = mxGetPr(X_m);
	F = mxGetScalar(F_m);
	cent = mxGetScalar(cent_m) == 1.0;
	/* Size of X */
	sz = mxGetDimensions(X_m);
	I = sz[0];
	J = sz[1];
	/* Create matrix outputs */
	t_m = mxCreateDoubleMatrix(I,F,mxREAL);
	p_m = mxCreateDoubleMatrix(F,J,mxREAL);
	Mean_m = mxCreateDoubleMatrix(1,J,mxREAL);
	/* Get pointer to real data */
	t = mxGetPr(t_m);
	p = mxGetPr(p_m);
	Mean = mxGetPr(Mean_m);
	/* Create temporary arrays */
	T_m = mxCreateDoubleMatrix(I,1,mxREAL);
	T = mxGetPr(T_m);
	P_m = mxCreateDoubleMatrix(1,J,mxREAL);
	P = mxGetPr(P_m);
	/* Assign to plhs */
	switch (nlhs) {
		case 3:
			plhs[2] = Mean_m;
		case 2:
			plhs[1] = p_m;
		case 1:
		case 0:
			plhs[0] = t_m;
	}
	/* create isnanX */
	isnanX_m = mxCreateLogicalMatrix(I,J);
	isnanX = mxGetLogicals(isnanX_m);
	for (i=0; i<I*J; i++)
	{
		isnanX[i] = mxIsNaN(X[i]);
	}
	pcanipals(t, p, Mean, T, P, X, F, isnanX, cent, I, J);
	/* Destroy unneeded arrays */
	/* mxDestroyArray(isnanX_m); */
	/* mxDestroyArray(X_m); */
	/* mxDestroyArray(T_m); */
	/* mxDestroyArray(P_m); */
	/* switch (nlhs) { */
	/* 	case 0: */
	/* 	case 1: */
        /* 		mxDestroyArray(p_m); */
	/* 	case 2: */
	/* 		mxDestroyArray(Mean_m); */
	/* } */
}

void nanmean(double *Mean, const double *X, const bool *isnanX, 
const int I, const int J, const int D)
{
	int count, i, j, idx;
	const char *msg = "nanmean dimension must be 1 or 2\n";
	if (D == 1)
	{
		for (j=0; j<J; j++)
		{
			count = 0;
			for (i=0; i<I; i++)
			{
				idx = i + I*j;
				if (!isnanX[idx])
				{
					Mean[j] += X[idx];
					count++;
				}
			}
			Mean[j] /= count;
		}		
	}
	else if (D == 2) {
		for (i=0; i<I; i++)
		{
			count = 0;
			for (j=0; j<J; j++)
			{
				idx = i + I*j;
				if (!isnanX[idx])
				{
					Mean[i] += X[idx];
					count++;
				}
			}
			Mean[i] /= count;
		}		
	}
	else {
        mxErrMsgTxt(msg);
	}
}

void pcanipals(double *t, double *p, double *Mean,
	double *T, double *P,
	double *X, const int F,
	const bool *isnanX, const bool cent, const int I, const int J)
{
	double Fit, FitOld, norm_sq, norm, X_pred, X_err;
	int i, j, idx, f, it;
	if (cent)
	{
		nanmean(Mean,X,isnanX,I,J,1);
		for (j=0; j<J; j++)
		{
			/* Center data */
			for (i=0; i<I; i++)
			{
				idx = i + I*j;
				if (!isnanX[idx])
				{
					X[idx] -= Mean[j];
				}
			}
		}
	}
	
	/* determine principal components */
	for (f=0; f<F; f++)
	{
		it = 0;
		nanmean(T,X,isnanX,I,J,2);
		nanmean(P,X,isnanX,I,J,1);
		
		Fit = 2.;
		FitOld = 3.;
		while (
			(fabs(Fit-FitOld)/FitOld > FIT_CRIT) &&
			(it < MAX_IT)
			)
		{
			FitOld = Fit;
			it++;
			
			for (j=0; j<J; j++)
			{
				norm_sq = 0;
				P[j] = 0.;
				for (i=0; i<I; i++)
				{
					idx = i + I*j;
					if (!isnanX[idx])
					{
						P[j] += T[i]*X[idx];
						norm_sq += T[i]*T[i];
					}
				}
				P[j] /= norm_sq;
			}
			norm_sq = 0;
			for (j=0; j<J; j++)
			{
				norm_sq += P[j]*P[j];
				/* mexPrintf("P[%d] = %g\n",j,P[j]); */
			}
			norm = sqrt(norm_sq);
			/* mexPrintf("norm=%g\n",norm); */
			for (j=0; j<J; j++)
			{
				P[j] /= norm;
				/* mexPrintf("P[%d] = %g\n",j,P[j]); */
			}
			
			for (i=0; i<I; i++)
			{
				norm_sq = 0;
				T[i] = 0.;
				for (j=0; j<J; j++)
				{
					idx = i + I*j;
					if (!isnanX[idx])
					{
						T[i] += P[j]*X[idx];
						norm_sq += P[j]*P[j];
					}
				}
				T[i] /= norm_sq;
				/* mexPrintf("T[%d] = %g\n",j,T[i]); */
			}
			
			/* Calculate fit */
			Fit = 0.;
			for (i=0; i<I; i++) {
				for (j=0; j<J; j++)
				{
					idx = i + I*j;
					if (!isnanX[idx])
					{
						X_pred = T[i]*P[j];
						X_err = X[idx] - X_pred;
						Fit += X_err*X_err;
					}
				}
			}
			/* mexPrintf("fit=%g\n",Fit); */
		}
		/* Store this component */
		for (i=0; i<I; i++) {
			idx = i + I*f;
			/* mexPrintf("i=%d, f=%d, idx=%d\n",i,f,idx); */
			t[idx] = T[i];
		}
		for (j=0; j<J; j++) {
			idx = f + F*j;
			/* mexPrintf("j=%d, f=%d, idx=%d\n",j,f,idx); */
			p[idx] = P[j];
		}
		/* Calculate new X */
		for (i=0; i<I; i++) {
			for (j=0; j<J; j++)
			{
				idx = i + I*j;
				if (!isnanX[idx])
				{
					X_pred = T[i]*P[j];
					X[idx] -= X_pred;
				}
			}
		}
	}
}
