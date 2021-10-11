unit mainu;
{
This program was created to help show you how to display 3D models without using DirectX, OpenGl...
but instead just your own code.

Feel free to change anything you want.
You might try adding different types of shapes to the model like cubes, pyramids, cylinders...

My email address is greijos@hotmail.com
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    Button1: TButton;
    Button2: TButton;
    ScrollBar3: TScrollBar;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  tpoint3d = record
     x,y,z: real;
  end;
  TLine = record
      p1,p2: tpoint3d; // coordinates of the 2 points on the ends of the line segment
  end;

var
  Form1: TForm1;
   lines: array of TLine; // all the lines in a 3D wireframe model

   mv: integer; // the vertical middle
   mh: integer; // the horizontal middle
   h,v: real; // the angles
   cosh,sinh,cosv,sinv: real;
   // precalculated trig values for xyztox and xyztoy functions
   sz: real; // magnification
   
implementation

{$R *.DFM}
function xyztox(x,y,z: real): integer;
begin
     result:=mh+round((x*cosh+z*sinh)*sz);
end;

function xyztoy(x,y,z: real): integer;
begin
     result:=mv+round(sz*(y*cosv+(-x*sinh+z*cosh)*sinv));
end;
{ the above 2 functions were created with math related to the projection of a point in space onto a 2D graph.
It is quite difficult to explain the math but I have created a program to help illustrate how the math works.

If you want to get this illustration program or have any specific questions, contact me about it.
}

procedure UpdateDisplay;
var
  bit1: tbitmap;
  x: integer;
begin
     // start by updating the settings for drawing the display
     mv:=form1.clientheight shr 1; // same as div 2
     mh:=form1.clientwidth shr 1;
     cosh:=cos(h);
     sinh:=sin(h);
     cosv:=cos(v);
     sinv:=sin(v);
     // settings now updated
     bit1:=tbitmap.create;
     bit1.height:=form1.clientheight;
     bit1.width:=form1.clientwidth;
     // now the dimensions of the bitmap are updated
     for x:=high(lines) downto 0 do
     with bit1.canvas do
     begin
          moveto(xyztox(lines[x].p1.x,lines[x].p1.y,lines[x].p1.z),xyztoy(lines[x].p1.x,lines[x].p1.y,lines[x].p1.z));
          lineto(xyztox(lines[x].p2.x,lines[x].p2.y,lines[x].p2.z),xyztoy(lines[x].p2.x,lines[x].p2.y,lines[x].p2.z));
     end;
     form1.canvas.draw(0,0,bit1); // draw the bitmap on the form to show the user the update
     bit1.free;
     // free the bitmap so it doesn't waste memory
end;

procedure Addline(ln1: TLine);
begin
     SetLength(lines,high(lines)+2);
     lines[high(lines)]:=ln1;
end;

procedure AddSphere(r: real; c: tpoint3d);
// r = the radius of the sphere
// c = the centre point of the sphere
var
  ln1: tline;
  x,y: integer;
  lat,long: real;
  cr: real; // the radius of a circle inside the sphere
begin
     for y:=-3 to 3 do // draw lines in circles parallel to the equator
     begin
          lat:=y*pi/6;
          ln1.p1.y:=r*sin(lat)+c.y;
          ln1.p2.y:=ln1.p1.y;
          // calculated the y coordinate of a circle in the sphere
          for x:=0 to 12 do
          begin
               long:=x*pi/6;
               cr:=r*cos(lat);
               ln1.p1:=ln1.p2;
               ln1.p2.x:=cr*cos(long)+c.x;
               ln1.p2.z:=cr*sin(long)+c.z;
               if x<>0 then
                  Addline(ln1);
          end;
     end;
     for x:=0 to 12 do // reverse the wire pattern so it looks like a grid
     // draw the pattern parallel to the meridians
     begin
          long:=x*pi/6;
          for y:=-3 to 3 do
          begin
               lat:=y*pi/6;
               ln1.p1:=ln1.p2;
               cr:=r*cos(lat);
               ln1.p2.x:=cr*cos(long)+c.x;
               ln1.p2.z:=cr*sin(long)+c.z;
               ln1.p2.y:=r*sin(lat)+c.y;
               // calculated the y coordinate of a circle in the sphere
               if y<>-3 then
                  Addline(ln1);
          end;
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     randomize; // generate a random seed so the random function won't keep returning the same results.
     sz:=1;
     h:=scrollbar1.position*pi/180;
     v:=scrollbar2.position*pi/180;
     // set initial values
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
     UpdateDisplay;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin // update the horizontal rotation angle
     h:=scrollbar1.position*pi/180;
     updatedisplay;
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin // update the vertical rotation angle
     v:=scrollbar2.position*pi/180;
     updatedisplay;
end;

procedure TForm1.Button1Click(Sender: TObject);
var // create a random sphere
  c: tpoint3d;
begin
     c.x:=random(300-150);
     c.y:=random(300-150);
     c.z:=random(300-150);
     AddSphere(random(50),c); // add the sphere to the model
     updatedisplay; // show the changes to the model
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     lines:=nil; // clear all of the information out of the lines array
     updatedisplay; // show the changes to the model
end;

procedure TForm1.ScrollBar3Change(Sender: TObject);
begin // update the magnification of the model
     sz:=scrollbar3.position/20;
     updatedisplay;
end;

end.
