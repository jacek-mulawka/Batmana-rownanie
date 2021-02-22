unit Batmana_Rownanie;{21.02.2021 z 16.11.2011}

//
// MIT License
//
// Copyright (c) 2011 Jacek Mulawka
//
// j.mulawka@interia.pl
//
// https://github.com/jacek-mulawka
//

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Spin, ExtCtrls, TAGraph, TASeries,
  GLLCLViewer, GLScene, GLObjects,
  Math;

type
  TPunkt_Real_r = record
    x,
    y
      : real;
  end;//---//TPunkt_Real_r

  { TBatmana_Rownanie_Form }

  TBatmana_Rownanie_Form = class(TForm)
    GLCamera1: TGLCamera;
    Obraz_Image: TImage;
    Postep_Label: TLabel;
    Punkty_GLDummyCube: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    Wykres_ChartLineSeries1: TLineSeries;
    Zero_GLSphere: TGLSphere;
    ProgressBar1: TProgressBar;
    Obraz_TabSheet: TTabSheet;
    GLScene_TabSheet: TTabSheet;
    Wykres_Chart: TChart;
    Wykres_TabSheet: TTabSheet;
    X_Skok_Etykieta_Label: TLabel;
    X_Skok_FloatSpinEdit: TFloatSpinEdit;
    Y_Skok_Etykieta_Label: TLabel;
    Y_Od_FloatSpinEdit: TFloatSpinEdit;
    Y_Od_Etykieta_Label: TLabel;
    X_Od_Etykieta_Label: TLabel;
    X_Od_FloatSpinEdit: TFloatSpinEdit;
    Rysuj_Button: TButton;
    PageControl1: TPageControl;
    Ustawienia_TabSheet: TTabSheet;
    Y_Skok_FloatSpinEdit: TFloatSpinEdit;
    procedure FormShow( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
    procedure Rysuj_ButtonClick( Sender: TObject );
  private
    punkt_real_r_t : array of TPunkt_Real_r;
    procedure Punkt_Dodaj( const x_f, y_f : real );
    procedure Punkty_Zwolnij_Wszystkie();
    procedure Batman_Rownanie_1( const x_f, y_f, x_abs_f : real );
    procedure Batman_Rownanie_2_6( const x_f, x_abs_f : real );
  public

  end;

var
  Batmana_Rownanie_Form: TBatmana_Rownanie_Form;

implementation

{$R *.lfm}

//      ***      Funkcje      ***      //

//Funkcja Punkt_Dodaj().
procedure TBatmana_Rownanie_Form.Punkt_Dodaj( const x_f, y_f : real );
var
  zti : integer;
begin

  if   (  IsNan( x_f )  )
    or (  IsNan( y_f )  ) then
    Exit; // Tutaj wyjątki nie łapią Sqrt() z liczb ujemnych.

  zti := Length( punkt_real_r_t );
  SetLength( punkt_real_r_t, zti + 1 );
  punkt_real_r_t[ zti ].x := x_f;
  punkt_real_r_t[ zti ].y := y_f;

end;//---//Funkcja Punkt_Dodaj().

//Funkcja Punkty_Zwolnij_Wszystkie().
procedure TBatmana_Rownanie_Form.Punkty_Zwolnij_Wszystkie();
var
  i : integer;
begin

  SetLength( punkt_real_r_t, 0 );

  Wykres_ChartLineSeries1.Clear();

  for i := Punkty_GLDummyCube.Count - 1 downto 0 do
    Punkty_GLDummyCube.Children[ i ].Free();

end;//---//Funkcja Punkty_Zwolnij_Wszystkie().

//Funkcja Batman_Rownanie_1().
procedure TBatmana_Rownanie_Form.Batman_Rownanie_1( const x_f, y_f, x_abs_f : real );
var
  ztr : real;
begin

  try
    ztr :=
      (
          Power(  ( x_f / 7 ), 2  )
        * Sqrt(   Abs(  x_abs_f - 3  ) / (  x_abs_f - 3  )  )
        + Power(  ( y_f / 3 ), 2  )
        //* Sqrt(   Abs(  y_f + 3 * Sqrt( 33 ) / 7  ) / (  y_f + 3 * Sqrt( 33 ) / 7  )   ) - 1 // Przyśpieszenie obliczeń.
        * Sqrt(   Abs(  y_f + 2.4619554199  ) / (  y_f + 2.4619554199  )   ) - 1
      );

    if Abs( ztr ) <= 0.00125 then
      Punkt_Dodaj( x_f, y_f );

  except
  end;//---//try

end;//---//Funkcja Batman_Rownanie_1().

//Funkcja Batman_Rownanie_2_6().
procedure TBatmana_Rownanie_Form.Batman_Rownanie_2_6( const x_f, x_abs_f : real );
var
  y_l : real;
begin

  try // 2 - ogon.
    y_l :=
      (
          Abs( x_f / 2 )
        //- (   (  3 * Sqrt( 33 ) - 7  ) / 112   ) // Przyśpieszenie obliczeń.
        - 0.0913722137 * Power( x_f, 2 )
        - 3
        + Sqrt(    1 - Power(   (  Abs( x_abs_f - 2 ) - 1  ), 2   )    )
      );
    Punkt_Dodaj( x_f, y_l );
  except
  end;//---//try 2.


  try // 3 - boki głowy.
    y_l :=
      (
          -4 //9
        * Sqrt(    Abs(   (  x_abs_f - 1  ) * (  x_abs_f - 0.75  )   ) / (  1 - x_abs_f ) * (  x_abs_f - 0.75  )    )
        -  1.75 * x_abs_f //8
      ) + 3.75; //
    Punkt_Dodaj( x_f, y_l );
  except
  end;//---//try 3.


  try // 4 - czubki uszu.
    y_l :=
      (
          1 * x_abs_f //3
        + 0.75
        * Sqrt(    Abs(    (  x_abs_f - 0.75  ) * (  x_abs_f - 0.5 )    ) / ( 0.75 - x_abs_f ) * (  x_abs_f - 0.5  )    )
      ) + 1.5; //
    Punkt_Dodaj( x_f, y_l );
  except
  end;//---//try 4.


  try // 5 - czubek głowy.
    y_l :=
      (
          2.0 //2.25
        * Sqrt(   Abs(  ( x_f - 0.5 ) * ( x_f + 0.5 )  ) / (  ( 0.5 - x_f ) * ( 0.5 + x_f )  )   )
      );
    Punkt_Dodaj( x_f, y_l );
  except
  end;//---//try 5.


  try // 6 - górne wewnętrzne skrzydła.
    y_l :=
      (
          2.7105237087 //6 * Sqrt( 10 ) / 7 // Przyśpieszenie obliczeń.
        + (  1.5 - 0.5 * x_abs_f  )
        * Sqrt(   Abs(  x_abs_f - 1  ) / (  x_abs_f - 1  )   )
        - 1.3552618544 //6 * Sqrt( 10 ) / 14 // Przyśpieszenie obliczeń.
        * Sqrt(   4 - Power(  x_abs_f - 1, 2  )   )
      );
    Punkt_Dodaj( x_f, y_l );
  except
  end;
  //---//try 6.

end;//---//Funkcja Batman_Rownanie_2_6().

//---//      ***      Funkcje      ***      //---//


//FormShow().
procedure TBatmana_Rownanie_Form.FormShow( Sender: TObject );
begin

  Zero_GLSphere.Visible := false;

  Obraz_Image.Picture.Bitmap.Canvas.Pen.Color := clYellow;

  PageControl1.Align := alClient;

  // Coś nie odświeża dobrze jeżeli nie wyświetli się najpierw zakładki.
  //PageControl1.ActivePage := GLScene_TabSheet;
  PageControl1.ActivePage := Obraz_TabSheet;
  //---// Coś nie odświeża dobrze jeżeli nie wyświetli się najpierw zakładki.

  PageControl1.ActivePage := Ustawienia_TabSheet;

  Rysuj_Button.SetFocus();

  // Test. //???
  //X_Skok_FloatSpinEdit.Value := 0.1;
  //Y_Skok_FloatSpinEdit.Value := 0.1;

end;//---//FormShow().

//FormDestroy().
procedure TBatmana_Rownanie_Form.FormDestroy( Sender: TObject );
begin

  Punkty_Zwolnij_Wszystkie();

end;//---//FormDestroy().

//Rysuj_ButtonClick().
procedure TBatmana_Rownanie_Form.Rysuj_ButtonClick( Sender: TObject );
var
  i : integer;
  x,
  y,
  x_abs,
  x_start,
  y_start,
  x_stop,
  y_stop,
  x_skok,
  y_skok,
  x_zakres,
  y_zakres
    : real;
  zt_gl_sphere : TGLSphere;
const
  obraz_margines_pikseli_c_l : real = 25;
begin

  Screen.Cursor := crHourGlass;
  Rysuj_Button.Enabled := false;

  Postep_Label.Caption := 'Postęp: zwalnianie elementów (ilość punktów: ' + Trim(  FormatFloat( '### ### ##0', Punkty_GLDummyCube.Count )  ) +').';
  ProgressBar1.Position := 0;

  Postep_Label.Repaint();
  Application.ProcessMessages();


  Punkty_Zwolnij_Wszystkie();
  Postep_Label.Caption := 'Postęp: przeliczanie.';

  Postep_Label.Repaint();
  Application.ProcessMessages();


  x_start := X_Od_FloatSpinEdit.Value;
  y_start := Y_Od_FloatSpinEdit.Value;
  x_stop := -x_start;
  y_stop := -y_start;
  x_skok := X_Skok_FloatSpinEdit.Value;
  y_skok := Y_Skok_FloatSpinEdit.Value;

  x_zakres := Abs( x_start - x_stop );
  y_zakres := Abs( y_start - y_stop );


  if x_skok <= 0 then
    x_skok := 0.1;

  if y_skok <= 0 then
    y_skok := 0.1;

  if x_zakres <= 0 then
    x_zakres := 1;

  if y_zakres <= 0 then
    y_zakres := 1;


  x := x_start;

  ProgressBar1.Max := Round(  x_zakres / x_skok ) * 2;

  i:= 0;

  while x < x_stop do
    begin

      x_abs := Abs( x );
      Batman_Rownanie_2_6( x, x_abs );
      y := y_start;

      if x_abs >= 3 then
        while y < y_stop do
          begin

            Batman_Rownanie_1( x, y, x_abs );

            y := y + y_skok;

          end;
        //---//while y

      x := x + x_skok;


      ProgressBar1.StepIt();


      inc( i );

      if i mod 100 = 0 then
        Application.ProcessMessages();

    end;
  //---//while x


  ProgressBar1.Position := 0;
  ProgressBar1.Max := Length( punkt_real_r_t );
  Postep_Label.Caption := 'Postęp: rysownie (ilość punktów: ' + Trim(   FormatFloat(  '### ### ##0', Length( punkt_real_r_t )  )   ) +').';
  Postep_Label.Repaint();

  Application.ProcessMessages();

  Obraz_Image.Picture.Bitmap.Canvas.Clear();
  Obraz_Image.Picture.Bitmap.Width := Obraz_TabSheet.Width;
  Obraz_Image.Picture.Bitmap.Height := Obraz_TabSheet.Height;
  Obraz_Image.Picture.Bitmap.Canvas.Brush.Color := clBlack;
  Obraz_Image.Picture.Bitmap.Canvas.Rectangle( 0, 0, Obraz_TabSheet.Width, Obraz_TabSheet.Height );
  Obraz_Image.Picture.Bitmap.Canvas.Brush.Color := clYellow;


  for i := 0 to Length( punkt_real_r_t ) - 1 do
    begin

      Wykres_ChartLineSeries1.AddXY( punkt_real_r_t[ i ].x, punkt_real_r_t[ i ].y, '' );


      zt_gl_sphere := TGLSphere.Create( Punkty_GLDummyCube );
      zt_gl_sphere.Parent := Punkty_GLDummyCube;
      zt_gl_sphere.Position.X := punkt_real_r_t[ i ].x;
      zt_gl_sphere.Position.Y := punkt_real_r_t[ i ].y;
      zt_gl_sphere.Radius := 0.1;


      x := punkt_real_r_t[ i ].x;
      y := punkt_real_r_t[ i ].y;

      // Przesunięcie, gdyż współrzędne obrazu są tylko dodatnie.
      x := x + x_zakres * 0.5;
      y := -y + y_zakres * 0.5;

      x := x * ( Obraz_Image.Picture.Bitmap.Width - obraz_margines_pikseli_c_l * 2 ) / x_zakres;
      y := y * ( Obraz_Image.Picture.Bitmap.Height - obraz_margines_pikseli_c_l * 2 ) / y_zakres;

      // Ustawia margines po bokach obrazka.
      x := x + obraz_margines_pikseli_c_l;
      y := y + obraz_margines_pikseli_c_l;


      //Obraz_Image.Picture.Bitmap.Canvas.Rectangle
      //  (
      //    Round( x ),
      //    Round( y ),
      //    Round( x + 10 ),
      //    Round( y + 10 )
      //  );

      Obraz_Image.Picture.Bitmap.Canvas.EllipseC
        (
          Round( x ),
          Round( y ),
          Round( 5 ),
          Round( 5 )
        );


      ProgressBar1.StepIt();


      if i mod 100 = 0 then
        Application.ProcessMessages();

    end;
  //---//for i := 0 to Length( punkt_real_r_t ) - 1 do


  Postep_Label.Caption := 'Postęp: oczekiwanie (ilość punktów: ' + Trim(   FormatFloat(  '### ### ##0', Length( punkt_real_r_t )  )   ) +').';
  Rysuj_Button.Enabled := true;
  Screen.Cursor := crDefault;

end;//---//Rysuj_ButtonClick().

end.

