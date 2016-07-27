#include "mex.h"
#include <stdio.h>

static double INF = 1000000000000;


void findPath(double* C, double* D, double* idx, double* dp, int m, int n) {
    int jtemp;

    
    int i, j;
    for (j=0; j<n; j++) {
        for (i=0; i<m; i++) {
            D[j*m + i] = 0;
            if (j>0 && i>0) {
                if (i%2 != 0) { /* if in an important row */
                    /*
                    if (D[j*m + i-1] < D[(j-1)*m + i-1]) {
                        D[j*m + i] = D[j*m + i-1] + C[j * m + i];
                    } else {
                        D[j*m + i] = D[(j-1)*m + i-1] + C[j * m + i];
                    }
                    */
                    D[j*m+i] = D[j*m + i-1] + C[j*m + i];
                } else {
                    if (D[(j-1)*m + i] < D[(j-1)*m + i-1]) {
                        D[j*m + i] = D[(j-1)*m + i] + C[j * m + i];
                    } else {
                        D[j*m + i] = D[(j-1)*m + i-1] + C[j * m + i];
                    }
                }
            } else if (j==0 && i==0) {
                D[j*m + i] = C[0];
            } else if (j==0) {
                if (i == 1) {
                    D[j*m + i] = D[0] + C[1];
                } else {
                    D[j*m + i] = INF;
                }
            } else {
                D[j*m + i] = D[(j-1)*m + i] + C[j*m + i];
            }
        }
    }
    
    
    i = m-1;
    j = n-1;
    dp[j*m + i] = 1;
    
    while (i>0 && j>0) {
        
        if (i%2 != 0) {
            /*
            if (D[j*m + i-1] < D[(j-1)*m + i-1]) {
                i = i-1;
            } else {
                i = i-1;
                j = j-1;
            }
            */
            i = i-1;
        } else {
            if (D[(j-1)*m + i] < D[(j-1)*m + i-1]) {
                j = j-1;
            } else {
                i = i-1;
                j = j-1;
            }
            
        }
        dp[j*m + i] = 1;
    }
    
    
}

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    int m=0, n=0;
    double* C;
    double* D;
    double* dp;
    double* idx;
            
    if (nrhs>0) {
        m = mxGetM(prhs[0]);
        n = mxGetN(prhs[0]);
        
        C = (double *) mxGetData(prhs[0]);

        plhs[0] = mxCreateDoubleMatrix(m,n, mxREAL);
        D = (double*) mxGetPr(plhs[0]);
        plhs[1] = mxCreateDoubleMatrix(n, 2, mxREAL);
        idx = (double*) mxGetPr(plhs[1]);
        plhs[2] = mxCreateDoubleMatrix(m, n, mxREAL);
        dp = (double*) mxGetPr(plhs[2]);

        findPath(C, D, idx, dp, m, n);


    } else {

    }

}
