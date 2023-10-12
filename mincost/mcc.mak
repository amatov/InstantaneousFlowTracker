bin_target : Tracker.dll

costexe.obj : H:\matlab\FSM\track\flowThreeFrames\mincost\costexe.cpp
	cl  -c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo /Focostexe.obj -IC:\Matlab\6.5\extern\include -IC:\Matlab\6.5\simulink\include /MD -O2 -Oy- -DNDEBUG H:\matlab\FSM\track\flowThreeFrames\mincost\costexe.cpp

costFunctions.obj : H:\matlab\FSM\track\flowThreeFrames\mincost\costFunctions.cpp
	cl  -c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo /FocostFunctions.obj -IC:\Matlab\6.5\extern\include -IC:\Matlab\6.5\simulink\include /MD -O2 -Oy- -DNDEBUG H:\matlab\FSM\track\flowThreeFrames\mincost\costFunctions.cpp

goldberg.obj : H:\matlab\FSM\track\flowThreeFrames\mincost\goldberg.cpp
	cl  -c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo /Fogoldberg.obj -IC:\Matlab\6.5\extern\include -IC:\Matlab\6.5\simulink\include /MD -O2 -Oy- -DNDEBUG H:\matlab\FSM\track\flowThreeFrames\mincost\goldberg.cpp

main.obj : H:\matlab\FSM\track\flowThreeFrames\mincost\main.cpp
	cl  -c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo /Fomain.obj -IC:\Matlab\6.5\extern\include -IC:\Matlab\6.5\simulink\include /MD -O2 -Oy- -DNDEBUG H:\matlab\FSM\track\flowThreeFrames\mincost\main.cpp

Tracker.obj : H:\matlab\FSM\track\flowThreeFrames\mincost\Tracker.cpp
	cl  -c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo /FoTracker.obj -IC:\Matlab\6.5\extern\include -IC:\Matlab\6.5\simulink\include /MD -O2 -Oy- -DNDEBUG H:\matlab\FSM\track\flowThreeFrames\mincost\Tracker.cpp

Tracker.dll : H:\matlab\FSM\track\flowThreeFrames\mincost\Tracker.h H:\matlab\FSM\track\flowThreeFrames\mincost\Array.h costexe.obj costFunctions.obj H:\matlab\FSM\track\flowThreeFrames\mincost\costFunctions.h goldberg.obj H:\matlab\FSM\track\flowThreeFrames\mincost\goldberg.h H:\matlab\FSM\track\flowThreeFrames\mincost\graphstruct.h main.obj H:\matlab\FSM\track\flowThreeFrames\mincost\structs.h Tracker.obj
	link /out:"Tracker.dll" /dll /export:mexFunction /MAP /LIBPATH:"C:\Matlab\6.5\extern\lib\win32\microsoft\msvc60" libmx.lib libmex.lib libmatlb.lib libmat.lib /implib:_lib9500.x  @Tracker_master.rsp 
	del "Tracker.map"
	del _lib9500.x
	if exist ".res" del ".res"

