#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <mex.h>
using namespace std;

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
    double *grid, *pos,*forb, *is_pac,*out,*food_map;
    int m=mxGetM(prhs[2]);
    int x=mxGetM(prhs[0]), y=mxGetN(prhs[0]);
    int x1=mxGetM(prhs[2]);
    int fm=mxGetM(prhs[4]),fn=mxGetN(prhs[4]);
    int i,j,k;
    plhs[0]=mxCreateDoubleMatrix(1,1, mxREAL);
    out = mxGetPr(plhs[0]);

    grid=mxGetPr(prhs[0]);
    pos =mxGetPr(prhs[1]);
    forb=mxGetPr(prhs[2]);
    is_pac=mxGetPr(prhs[3]);
    food_map=mxGetPr(prhs[4]);
    vector<vector<double> >fringe;
    vector<double> init;
    init.push_back(pos[0]);
    init.push_back(pos[1]);
    init.push_back(0);
    fringe.push_back(init);
    vector<vector<double> >closelist;
    double dist=-1;
    vector<double> cdist;
    int dfound=0;
    for(;;){
        if(fringe.empty())break;
        vector<double> cur=fringe.front();
        fringe.erase(fringe.begin());
        int ismember=0;
        for(i=0;i<closelist.size();i++){
            if(closelist[i][0]==cur[0]&&closelist[i][1]==cur[1]){
                ismember=1;break;
            }
        }
        if(!ismember){
            vector<double> ins;
            ins.push_back(cur[0]);ins.push_back(cur[1]);
            closelist.push_back(ins);
        }
        int cy=cur[0]-1,cx=cur[1]-1;
        if(food_map[cx*fm+cy]!=0){
//             dist=cur[2];break;
            cdist.push_back(cur[2]);dfound=1;
        }
        double na[]={0,0,0,0};
        double c_pos[]={cur[0],cur[1]};
        get_next_action(m,x,y,x1,grid,c_pos,forb,is_pac,na);
        if(na[0]!=0&&!dfound){
            int n1=cur[0]-1,n2=cur[1];
            int f1=0;
            for(i=0;i<closelist.size();i++)
                if(closelist[i][0]==n1&&closelist[i][1]==n2){
                    f1=1;break;
                }
            if(!f1)
            {
                vector<double> ins;
                ins.push_back(n1);ins.push_back(n2);ins.push_back(cur[2]+1);
                fringe.push_back(ins);
            }
        }
        if(na[1]!=0){
            int n1=cur[0]+1,n2=cur[1];
            int f1=0;
            for(i=0;i<closelist.size();i++)
                if(closelist[i][0]==n1&&closelist[i][1]==n2){
                    f1=1;break;
                }
            if(!f1)
            {
                vector<double> ins;
                ins.push_back(n1);ins.push_back(n2);ins.push_back(cur[2]+1);
                fringe.push_back(ins);
            }
        }
        if(na[2]!=0){
            int n1=cur[0],n2=cur[1]-1;
            int f1=0;
            for(i=0;i<closelist.size();i++)
                if(closelist[i][0]==n1&&closelist[i][1]==n2){
                    f1=1;break;
                }
            if(!f1)
            {
                vector<double> ins;
                ins.push_back(n1);ins.push_back(n2);ins.push_back(cur[2]+1);
                fringe.push_back(ins);
            }
        }
        if(na[3]!=0){
            int n1=cur[0],n2=cur[1]+1;
            int f1=0;
            for(i=0;i<closelist.size();i++)
                if(closelist[i][0]==n1&&closelist[i][1]==n2){
                    f1=1;break;
                }
            if(!f1)
            {
                vector<double> ins;
                ins.push_back(n1);ins.push_back(n2);ins.push_back(cur[2]+1);
                fringe.push_back(ins);
            }
        }        
        
    }
    dist=1e5;
    if(cdist.size()>0)
        for(i = 0; i < cdist.size();i++)
            if(cdist[i]<dist)dist=cdist[i];
    out[0]=dist;

}