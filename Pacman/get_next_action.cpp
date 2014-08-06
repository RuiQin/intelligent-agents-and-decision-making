
#include <stdio.h>
#include <stdlib.h>
#include <mex.h>

void get_next_action(int m,int x,int y,int x1,double *grid,double *pos,double *forb,
        double *is_pac,double*out){
    int i,j,k;
    double nposes[]={pos[0]-1,pos[1],pos[0]+1,pos[1],pos[0],pos[1]-1,pos[0],pos[1]+1};
    
    for(i = 0; i < 4; i++)
    {
        int cy=nposes[i*2], cx=nposes[i*2+1];
        int found=0;
        for(j=0;j<m;j++){
            if ( forb[j]==cy&&forb[j+x1]==cx)
            {
                found=1;break;
            }
       }
       cy-=1,cx-=1;
       if(grid[cy+x*cx]==1&&!(is_pac[0]==1&&found==1))
           out[i]=1;
       else
           out[i]=0;
        
    }

    
}
void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{
   /* more C/C++ code ... */
    double *grid, *pos,*forb, *is_pac,*out;
    int m=mxGetM(prhs[2]);
    int x=mxGetM(prhs[0]), y=mxGetN(prhs[0]);
    int x1=mxGetM(prhs[2]);
    int i,j,k;
    
    plhs[0]=mxCreateDoubleMatrix(4,1, mxREAL);
    out = mxGetPr(plhs[0]);

    grid=mxGetPr(prhs[0]);
    pos =mxGetPr(prhs[1]);
    forb=mxGetPr(prhs[2]);
    is_pac=mxGetPr(prhs[3]);
    
    double nposes[]={pos[0]-1,pos[1],pos[0]+1,pos[1],pos[0],pos[1]-1,pos[0],pos[1]+1};
    for(i = 0; i < 4; i++)
    {
        int cy=nposes[i*2], cx=nposes[i*2+1];
//         mexPrintf("cy:%d,cx:%d\n",cy,cx);
        int found=0;
        for(j=0;j<m;j++){
//             mexPrintf("fy:%g,fx:%g\n",forb[j],forb[j+x1]);
            if ( forb[j]==cy&&forb[j+x1]==cx)
            {
                found=1;break;
            }
       }
       cy-=1,cx-=1;
//        mexPrintf("%d,%g\n",cy+x*cx,grid[cy+x*cx]);
       if(grid[cy+x*cx]==1&&!(is_pac[0]==1&&found==1))
           out[i]=1;
       else
           out[i]=0;
        
    }

}

