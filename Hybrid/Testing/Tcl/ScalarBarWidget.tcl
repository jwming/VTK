package require vtk
package require vtkinteraction

# create pipeline
#
# create sphere to color
vtkSphereSource sphere
    sphere SetThetaResolution 20
    sphere SetPhiResolution 40

# Compute random scalars (colors) for each cell
vtkProgrammableAttributeDataFilter randomColors
    randomColors SetInput [sphere GetOutput]
    randomColors SetExecuteMethod colorCells

proc colorCells {} {
    vtkMath randomColorGenerator
    set input [randomColors GetInput]
    set output [randomColors GetOutput]
    set numCells [$input GetNumberOfCells]
    vtkFloatArray colors
	colors SetNumberOfTuples $numCells

    for {set i 0} {$i < $numCells} {incr i} {
        colors SetValue $i [randomColorGenerator Random 0 1]
    }

    [$output GetCellData] CopyScalarsOff
    [$output GetCellData] PassData [$input GetCellData]
    [$output GetCellData] SetScalars colors

    colors Delete; #reference counting - it's ok
    randomColorGenerator Delete
}
# mapper and actor
vtkPolyDataMapper mapper
    mapper SetInput [randomColors GetPolyDataOutput]
    eval mapper SetScalarRange [[randomColors GetPolyDataOutput] GetScalarRange]
vtkActor sphereActor
    sphereActor SetMapper mapper

# Create a scalar bar widget
vtkScalarBarWidget scalarBarWidget
set scalarBar [scalarBarWidget GetScalarBarActor]
$scalarBar SetLookupTable [mapper GetLookupTable]
$scalarBar SetTitle "Temperature"
[$scalarBar GetPositionCoordinate] SetCoordinateSystemToNormalizedViewport
[$scalarBar GetPositionCoordinate] SetValue 0.1 0.01
$scalarBar SetOrientationToHorizontal
$scalarBar SetWidth 0.8
$scalarBar SetHeight 0.17
$scalarBar SetNumberOfLabels 8

# Create graphics stuff
# Create the RenderWindow, Renderer and both Actors
#
vtkRenderer ren1
vtkRenderWindow renWin
    renWin AddRenderer ren1
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin
scalarBarWidget SetInteractor iren
ren1 AddActor sphereActor
renWin Render
scalarBarWidget EnabledOn

renWin SetSize 350 350

# render the image
#
iren AddObserver UserEvent {wm deiconify .vtkInteract}
[ren1 GetActiveCamera] Zoom 1.5
renWin Render


# prevent the tk window from showing up then start the event loop
wm withdraw .

