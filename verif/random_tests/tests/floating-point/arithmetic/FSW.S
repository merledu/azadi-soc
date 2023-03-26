li x4,20
FMV.S.X f1,x4
li x5,13
FMV.S.X f2,x5
FADD.S f3,f2,f1
FSW f3,0x2(x1) 	
FLW f4,0x2(x1) 	