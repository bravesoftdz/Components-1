// Copyright (c) 1999-2009 Rob Chandler, www.Helpware.net
// Code originally based on work done by Brad Stowers DFS.inc file
// and Mike Lischke's compilers.inc file (http://www.delphi-gems.com)
// VER80 Delphi 1
// VER90 Delphi 2
// VER100 Delphi 3
// VER120 Delphi 4
// VER130 Delphi 5
// VER140 Delphi 6
// VER150 Delphi 7
// VER160 Delphi 8
// VER170 Delphi 9 (2005)
// VER180 Delphi 10 (2006)
// VER190 Delphi 11 (2007)
// CodeGear Delphi 2007 for .NET 	 11.0 	 VER190
// CodeGear Delphi 2007 for Win32 	11.0 	VER180 and VER185
// VER200 Delphi 12 (2009)
//----------------------------------------------------------------------------------------------------------------------

{$ifdef CLR}  // Common Language Runtime symbol only defined for the .NET platform.
  {$define DELPHI.NET}
{$endif CLR}

{$ifdef Win32}

  {$define DELPHI_1_UP}
  {$define DELPHI_2_UP}
  {$define DELPHI_3_UP}
  {$define DELPHI_4_UP}
  {$define DELPHI_5_UP}
  {$define DELPHI_6_UP}
  {$define DELPHI_7_UP}
  {$define DELPHI_8_UP}
  {$define DELPHI_9_UP}
  {$define DELPHI_10_UP}
  {$define DELPHI_11_UP}
  {$define DELPHI_12_UP}

  {$define COMPILER_1_UP}
  {$define COMPILER_2_UP}
  {$define COMPILER_3_UP}
  {$define COMPILER_4_UP}
  {$define COMPILER_5_UP}
  {$define COMPILER_6_UP}
  {$define COMPILER_7_UP}
  {$define COMPILER_8_UP}
  {$define COMPILER_9_UP}
  {$define COMPILER_10_UP}
  {$define COMPILER_11_UP}
  {$define COMPILER_12_UP}

  {$ifdef VER80}
    {$undef DELPHI_2_UP}
    {$undef DELPHI_3_UP}
    {$undef DELPHI_4_UP}
    {$undef DELPHI_5_UP}
    {$undef DELPHI_6_UP}
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_2_UP}
    {$undef COMPILER_3_UP}
    {$undef COMPILER_4_UP}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_1}
    {$define DELPHI}
    {$define DELPHI_1}
  {$endif}

  {$IFDEF VER90}        //Delphi 2
    {$undef DELPHI_3_UP}
    {$undef DELPHI_4_UP}
    {$undef DELPHI_5_UP}
    {$undef DELPHI_6_UP}
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_3_UP}
    {$undef COMPILER_4_UP}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_2}
    {$define DELPHI}
    {$define DELPHI_2}
  {$ENDIF}

  {$ifdef VER93}
    {$undef COMPILER_3_UP}
    {$undef COMPILER_4_UP}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_2} // C_UP_UPB v1 compiler is really v2
    {$define CPPB}
    {$define CPPB_1}
  {$endif}

  {$IFDEF VER100}       //Delphi 3
    {$undef DELPHI_4_UP}
    {$undef DELPHI_5_UP}
    {$undef DELPHI_6_UP}
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_4_UP}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_3}
    {$define DELPHI}
    {$define DELPHI_3}
  {$ENDIF}

  {$ifdef VER110}
    {$undef COMPILER_4_UP}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_3}
    {$define CPPB}
    {$define CPPB_3}
  {$endif}

  {$IFDEF VER120}       //Delphi 4
    {$undef DELPHI_5_UP}
    {$undef DELPHI_6_UP}
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_4}
    {$define DELPHI}
    {$define DELPHI_4}
  {$ENDIF}

  {$ifdef VER125}
    {$undef COMPILER_5_UP}
    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_4}
    {$define CPPB}
    {$define CPPB_4}
  {$endif}

  {$IFDEF VER130}       //Delphi 5
    {$undef DELPHI_6_UP}
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_6_UP}
    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_5}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_5}
    {$else}
      {$define DELPHI}
      {$define DELPHI_5}
    {$endif}
  {$ENDIF}

  {$IFDEF VER140}       //Delphi 6
    {$undef DELPHI_7_UP}
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_7_UP}
    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_6}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_6}
    {$else}
      {$define DELPHI}
      {$define DELPHI_6}
    {$endif}
  {$ENDIF}

  {$IFDEF VER150}       //Delphi 7
    {$undef DELPHI_8_UP}
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_8_UP}
    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_7}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_7}
    {$else}
      {$define DELPHI}
      {$define DELPHI_7}
    {$endif}
  {$ENDIF}

  {$IFDEF VER160}       //Delphi 8
    {$undef DELPHI_9_UP}
    {$undef DELPHI_10_UP}
    {$undef DELPHI_12_UP}
    {$undef DELPHI_13_UP}

    {$undef COMPILER_9_UP}
    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_8}
  {$ENDIF}

  {$IFDEF VER170}       //Borland Delphi 9 (2005)
    {$undef DELPHI_10_UP}
    {$undef DELPHI_11_UP}
    {$undef DELPHI_12_UP}

    {$undef COMPILER_10_UP}
    {$undef COMPILER_11_UP}
    {$undef COMPILER_12_UP}

    {$define COMPILER_9}
  {$ENDIF}


  {$IFDEF VER180}       //CodeGear Delphi 11 (2007) .. OR ... Borland Developer Studio 2006 V10.0
    {$undef DELPHI_12_UP}

    {$undef COMPILER_12_UP}

    {$define COMPILER_11}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_11}
    {$else}
      {$define DELPHI}
      {$define DELPHI_11}
    {$endif}
  {$ENDIF}

  {$IFDEF VER185}       //CodeGear Delphi 11 (2007) win32
    {$undef DELPHI_12_UP}

    {$undef COMPILER_12_UP}

    {$define COMPILER_11}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_11}
    {$else}
      {$define DELPHI}
      {$define DELPHI_11}
    {$endif}
  {$ENDIF}

  {$IFDEF VER190}       //CodeGear Delphi 2007 V11 for .NET
    {$undef DELPHI_12_UP}

    {$undef COMPILER_12_UP}

    {$define COMPILER_11}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_11}
    {$else}
      {$define DELPHI}
      {$define DELPHI_11}
    {$endif}
  {$ENDIF}

  {$IFDEF VER200}       //CodeGear Delphi 2009 V12 / C++ Builder 2009
    {$define COMPILER_12}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_12}
    {$else}
      {$define DELPHI}
      {$define DELPHI_12}
    {$endif}
  {$ENDIF}


  //RWC: Not as forward compatible but it will do for now

  {$ifdef CPPB_3}
    {$define CPPB_3_UP}
  {$endif}

  {$ifdef CPPB_4}
    {$define CPPB_3_UP}
    {$define CPPB_4_UP}
  {$endif}

  {$ifdef CPPB_5}
    {$define CPPB_3_UP}
    {$define CPPB_4_UP}
    {$define CPPB_5_UP}
  {$endif}

  {$ifdef CPPB_3_UP}
    // C++ Builder requires this if you use Delphi components in run-time packages.
    {$ObjExportAll On}
  {$endif}

{$else (not Windows)}
  // Linux is the target
  {$define KYLIX}
  {$define KYLIX_1}
  {$define KYLIX_1_UP}
{$endif}

/////////////////////////////////////////////////////////////////////////////
//  Stop the Platform messages
/////////////////////////////////////////////////////////////////////////////

{$IFDEF DELPHI_6_UP}
{$warn SYMBOL_PLATFORM off}
{$warn UNIT_PLATFORM off}
{$ENDIF}

//----------------------------------------------------------------------------------------------------------------------

