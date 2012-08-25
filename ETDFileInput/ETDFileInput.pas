(**************************************************************************
** Filename: EDTFileInput.pas
**
** Description:
** This is the eyedat file io module.
**
***************************************************************************
**
** Modification History:
** 16.04.2004: Lasse Rautiainen, Joensuun Yliopisto
** - Delphi conversion from edtfio.c and edtfio.h files
** - Only file reading included
**
**************************************************************************)
unit ETDFileInput;

interface

uses Classes, dialogs;

const
  EDTFIO_MAX_DATA_ITEMS_IN_HEADER = 20;  // max number of data items that can be specified in header

  // data item ids
  EDTFIO_SCENE_NUMBER =         0;
  EDTFIO_POG_MAGNITUDE =        1;
  EDTFIO_HORZ_EYE_POSITION =    2;
  EDTFIO_VERT_EYE_POSITION =    3;
  EDTFIO_PUPIL_DIAMETER =       4;
  EDTFIO_EXTERNAL_DATA =        5;
  EDTFIO_MARK_FLAGS =           6;
  EDTFIO_MHT_STATUS =           7;
  EDTFIO_MHT_X_POSITION =       8;
  EDTFIO_MHT_Y_POSITION =       9;
  EDTFIO_MHT_Z_POSITION =       10;
  EDTFIO_MHT_AZIMUTH =          11;
  EDTFIO_MHT_ELEVATION =        12;
  EDTFIO_MHT_ROLL =             13;
  EDTFIO_LEFT_PUPIL_DIAMETER =  14;
  EDTFIO_RIGHT_PUPIL_DIAMETER = 15;
  EDTFIO_HORZ_EYE_POS_WRT_HD =  16;
  EDTFIO_VERT_EYE_POS_WRT_HD =  17;
  EDTFIO_NO_ITEM =              255;
  EDTFIO_NUMBER_OF_DATA_ITEMS = 18;  // number of different data items

  // error codes
  EDTFIO_NO_ERROR =                          0;
  EDTFIO_INSUFFICIENT_MEMORY =             -10;
  EDTFIO_NO_RECORD_FLAG =                  -11;
  EDTFIO_DUPLICATE_RECORD_FLAG =           -12;
  EDTFIO_MISSING_RECORD_FLAG =             -13;
  EDTFIO_CANNOT_OPEN_DISK_FILE =           -14;
  EDTFIO_ERROR_READING_FILE =              -15;
  EDTFIO_NOT_PC_EYEDAT_FILE =              -16;
  EDTFIO_ERROR_WRITING_TO_FILE =           -17;
  EDTFIO_ILLEGAL_RECORD_FLAG =             -18;
  EDTFIO_CLOCK_ERROR =                     -19;
  EDTFIO_ILLEGAL_SEGMENT_REQUEST =         -20;
  EDTFIO_END_OF_FILE =                     -21;

  { Types }
  EDTFIO_USER_DESCRIPTION_SIZE = 200;
  EDTFIO_TOTAL_NUMBER_OF_SEGMENTS = 169; // max number ( 168 User + 1 EOF ) of segments allowed in file
  EDTFIO_PATHLENGTH = 132;  // number of characters to save for DOS filename path

  STRINGS_IDENTICAL = 0;

  // system types
  EDTFIO_MODEL_ETS =      50;
  EDTFIO_MODEL_EYEHEAD = 100;
  EDTFIO_MODEL_210 =     210;
  EDTFIO_MODEL_1992 =   1994;
  EDTFIO_MODEL_1994 =   1994;
  EDTFIO_MODEL_1996 =   1998;
  EDTFIO_MODEL_1998 =   1998;
  EDTFIO_MODEL_3000 =   3000;
  EDTFIO_MODEL_4000 =   4000;
  EDTFIO_MODEL_5000 =   5000;

  EDTFIO_ITEM_ID =   0;  // subscript for id value in data items array
  EDTFIO_ITEM_SIZE = 1;  // subscript for size value in data items array

  BYTE_STR =    'BYTE';
  EVMWORD_STR = 'EVMWORD';
  WORD_STR =    'WORD';
  LONGWRD_STR = 'LONGWRD';

  // possible bit lengths of the above data items
  EDTFIO_BYTE_SIZE =    8;
  EDTFIO_WORD_SIZE =		16;
  EDTFIO_EVMWORD_SIZE = 10;
  EDTFIO_LONGWRD_SIZE = 32;

  True = 1;
  False = 0;

  // segment types
  RECORD_USER_SEGMENT =        $FF;
  RECORD_PSEUDO_SEGMENT =      $FE;
  END_OF_FILE_SEGMENT =        $FD;
  NULL_SEGMENT =						   $00;

  // STATUS byte bit flags
  EYEDAT_USER_RECORD_BIT =     $80;  // User Record Flag
  EYEDAT_PSEUDO_RECORD_BIT =   $40;  // Pseudo Record Flag
  EYEDAT_STOP_BIT =            $20;  // Stop Flag
  EYEDAT_OVERTIME_BIT =        $10;  // Overtime Flag - One word following with no of overtimes
  EYEDAT_EXTERNAL_DATA_BIT =   $08;  // External Data ( XDAT ) Flag - One word following with value
  EYEDAT_MARK_BIT =            $04;  // Mark Flag - One byte following with mark value
  EYEDAT_UNUSED_BIT =          $02;  // Unused Flag
  EYEDAT_RESERVED_BIT =        $00;  // Reserved Flag - If set another status flag byte is to follow to allow for future expansion

  
  // Mask for a 10 bit EVM Word
  EYEDAT_EVMWORD_MASK =        $3FF;

  item_names: array [0..EDTFIO_NUMBER_OF_DATA_ITEMS-1] of String = ( 'SCENE_NUMBER',
    'POG_MAGNITUDE', 'HORZ_EYE_POS', 'VERT_EYE_POS', 'PUPIL_DIAMETER', 'EXTERNAL_DATA',
    'MARK_FLAGS', 'MHT_STATUS', 'MHT_X_POSITION', 'MHT_Y_POSITION', 'MHT_Z_POSITION',
    'MHT_AZIMUTH', 'MHT_ELEVATION', 'MHT_ROLL', 'LPUPIL_DIAMETER', 'RPUPIL_DIAMETER',
    'HEYE_POS_WRT_HD', 'VEYE_POS_WRT_HD'  );


type
  TEdtfio_Segment = record
    segment_type: Byte;       // EYEDAT User or Pseudo segment flag, 0xFF = User Segment; 0xFE = Pseudo Segment
	  disk_file_address: LongInt;  // Segment starting address on disk file
	  starting_time: LongInt;      // Segment starting time selected by the user
	  stopping_time: LongInt;      // Segment stopping time showing elapsed time
	end;

  TEdtfio_File_Parameters = record
    // public variables -- may be modified/accessed by user
    eyedat_version: array [0..9] of AnsiChar;   // EYEDAT Version of the recorded data.
    recorded_month: array [0..19] of AnsiChar;   // Month that the EYEDAT file was recorded
    recorded_day: integer;        // Day of the week that the EYEDAT file was recorded
    recorded_year: integer;       // Year that the EYEDAT file was recorded
    recorded_hour: integer;       // Hour time of day that the EYEDAT file was recorded
    recorded_minute: integer;     // Minutes that the EYEDAT file was recorded
    recorded_second: integer;     // Seconds that the EYEDAT file was recorded
    recorded_hsecond: integer;    // Fraction seconds that the EYEDAT file was recorded
    evm_system_type: integer;     // EVM System Type defined as the system model number
    update_rate: integer;         // EVM Update Rate in Hertz as define above in header
    number_of_data_items: integer;// Number of data items to be recorded in disk file
    data_items: array [0..19,0..1] of Byte; // Array of Data Item desciptions
             // Each data item described by 2 elements
						 // Element 1 = Data Item Id  ( see list above )
						 // Element 2 = Data Item Size ( in bits )
    user_description: array [0..EDTFIO_USER_DESCRIPTION_SIZE-1] of AnsiChar;  // 200 Character User Description of EYEDAT Disk File
    clock_field_counter: Longword;
    number_of_user_segments: integer; // Total number of user segments on this disk file
    current_file_size: Longint;       // Total number of bytes written to file

    // private variables -- may not be accessed/modified by user
	  // used for both writing and reading
    path: array [0..EDTFIO_PATHLENGTH-1] of AnsiChar;
    stream: TStream;                   // Disk File I/O Stream
    access_mode: integer;           // read or write
    bit_cnt: integer;               // file i/o bit count
    bit_buf: Byte;                  // file i/o bit buffer
    item_present: array [0..EDTFIO_NUMBER_OF_DATA_ITEMS-1] of integer;
    item_size: array [0..EDTFIO_NUMBER_OF_DATA_ITEMS-1] of Byte; // number of bits in item (see above)
    internal_field_count: Longword;
    max_pseudo_segment_interval: integer; // Maximum number of minutes allowed in 1 pseudo segment
    number_of_pseudo_segments: integer;   // Total number of pseudo segments on this disk file
    segment_entry_counter: Byte;          // Current segment array element
    pseudo_segment_entry_counter: Byte;   // Current pseudo segment array element
    segment_table: array [0..EDTFIO_TOTAL_NUMBER_OF_SEGMENTS-1] of TEdtfio_Segment; // Array of segment info
    // used for writing
    eyedat_recording_flag: integer;       // EYEDAT recording in progress flag
    file_initialized: integer;            // TRUE if EYEDAT file has been initialized
    next_pseudo_seg_count: Longword;      // field number at which to generate next pseudo segment
    // used for reading
    segment_table_index: array [0..EDTFIO_TOTAL_NUMBER_OF_SEGMENTS-1] of Byte;
    last_user_segment_number: ShortInt;
  end;

  TEdtfio_Field = record
    // only used when reading
    segment_number: Shortint;      // EYEDAT current user segment number
    double_clock: LongInt;    // EYEDAT clock value is a double precision fields count
    end_of_file_flag: Shortint;    // EYEDAT end of file flag   (1 = SET)
    // used when reading or writing
    record_flag: Shortint;         // EYEDAT record flag (1 = SET)
    stop_flag: Shortint;           // EYEDAT stop flag   (1 = SET)
    overtimes: Shortint;           // EYEDAT overtime flag = number
    xdat_flag: Shortint;           // EYEDAT XDAT flag   (1 = SET)
    xdat_value: LongInt;      // EYEDAT recorded external data value
    mark_value: LongInt;      // EYEDAT mark flag = flag no.
    scene_number: LongInt;    // current scene plane number
    point_of_gaze_magnitude: LongInt; // agnitude of vector from eye to intersecting scene
    horz_eye_pos: LongInt;            // Horizontal Eye Position
    vert_eye_pos: LongInt;            // Vertical Eye Position
    horz_eye_pos_wrt_hd: LongInt;     // Horizontal Eye Position with respect to head
    vert_eye_pos_wrt_hd: LongInt;     // Vertical Eye Position with respect to head
    pupil_diameter: LongInt;          // Pupil Diameter
    right_pupil_diameter: LongInt;    // right pupil diameter
    mht_status: LongInt;              // Magnetic Head Tracker Status
    mht_x_pos: LongInt;               // Magnetic Head Tracker X position
    mht_y_pos: LongInt;               // Magnetic Head Tracker Y position
    mht_z_pos: LongInt;               // Magnetic Head Tracker Z position
    mht_azimuth: LongInt;             // Magnetic Head Tracker Azimuth Angle
    mht_elevation: LongInt;           // Magnetic Head Tracker Elevation Angle
    mht_roll: LongInt;                // Magnetic Head Tracker Roll Angle
  end;



function edtfio_close_file(var efp: TEdtfio_File_Parameters): integer;
function close_file_after_reading(var efp: TEdtfio_File_Parameters): integer;
function edtfio_open_file(path: PAnsiChar; var efp: TEdtfio_File_Parameters): integer;
function open_file_for_reading(path: PAnsiChar; var efp: TEdtfio_File_Parameters): integer;
function edtfio_read_field(var efp: TEdtfio_File_Parameters; var field: TEdtfio_Field): integer;
procedure process_edt_error(szFilename: String; error_code: integer);

implementation

uses Sysutils, Scanf;

(**************************************************************************
** edtfio_close_file
**
** This routine closes an EYEDAT file.
**************************************************************************)
function edtfio_close_file(var efp: TEdtfio_File_Parameters): integer;
begin
  result := close_file_after_reading(efp);
end;

(**************************************************************************
** close_file_after_reading
**
** This routine releases memory allocated when the file was opened and
** closes the file.
**************************************************************************)

function close_file_after_reading(var efp: TEdtfio_File_Parameters): integer;
begin
	efp.stream.Destroy;
	Result := EDTFIO_NO_ERROR;
end;

(**************************************************************************
** edtfio_open_file
**
** This routine open an EYEDAT file in the appropriate mode.
**************************************************************************)

function edtfio_open_file(path: PAnsiChar; var efp: TEdtfio_File_Parameters): integer;
begin
  Result := open_file_for_reading(path, efp);
end;

function convert_item_name_to_id(str: PAnsiChar): integer;
var
  StringValue: string;
begin
  StringValue := string(str);
	if (  (CompareStr( StringValue, (item_names[EDTFIO_SCENE_NUMBER])) ) = 0)  then result := EDTFIO_SCENE_NUMBER
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_POG_MAGNITUDE]) ) = 0)) then result := EDTFIO_POG_MAGNITUDE
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_HORZ_EYE_POSITION]) ) = 0)) then result := EDTFIO_HORZ_EYE_POSITION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_VERT_EYE_POSITION]) ) = 0)) then result := EDTFIO_VERT_EYE_POSITION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_PUPIL_DIAMETER]) ) = 0)) then result := EDTFIO_PUPIL_DIAMETER
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_EXTERNAL_DATA]) ) = 0)) then result := EDTFIO_EXTERNAL_DATA
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MARK_FLAGS]) ) = 0)) then result := EDTFIO_MARK_FLAGS
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_STATUS]) ) = 0)) then result := EDTFIO_MHT_STATUS
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_X_POSITION]) ) = 0)) then result := EDTFIO_MHT_X_POSITION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_Y_POSITION]) ) = 0)) then result := EDTFIO_MHT_Y_POSITION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_Z_POSITION]) ) = 0)) then result := EDTFIO_MHT_Z_POSITION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_AZIMUTH]) ) = 0)) then result := EDTFIO_MHT_AZIMUTH
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_ELEVATION]) ) = 0)) then result := EDTFIO_MHT_ELEVATION
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_MHT_ROLL]) ) = 0)) then result := EDTFIO_MHT_ROLL
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_LEFT_PUPIL_DIAMETER]) ) = 0)) then result := EDTFIO_LEFT_PUPIL_DIAMETER
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_RIGHT_PUPIL_DIAMETER]) )= 0) ) then result := EDTFIO_RIGHT_PUPIL_DIAMETER
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_HORZ_EYE_POS_WRT_HD]) ) = 0)) then result := EDTFIO_HORZ_EYE_POS_WRT_HD
	else if(  (CompareStr( StringValue, (item_names[EDTFIO_VERT_EYE_POS_WRT_HD]) ) = 0)) then result := EDTFIO_VERT_EYE_POS_WRT_HD
	else if(  (CompareStr( StringValue, ('NULL') ) = 0)) then result := EDTFIO_NO_ITEM
	else result := EDTFIO_ERROR_READING_FILE
end;

(**************************************************************************
** convert_item_size_to_value
**
** This routine reads the string that specifies the bit size of the current
** data item and returns the number of bits that the string represents.
**************************************************************************)

function convert_item_size_to_value( str: PAnsiChar ): ShortInt;
begin
	if ( strcomp (str, BYTE_STR ) = STRINGS_IDENTICAL ) then
  begin
		result := EDTFIO_BYTE_SIZE;
    exit
  end;
	if ( strcomp ( str, EVMWORD_STR ) = STRINGS_IDENTICAL ) then
  begin
		result := EDTFIO_EVMWORD_SIZE;
    exit
  end;
	if ( strcomp ( str, WORD_STR ) = STRINGS_IDENTICAL ) then
  begin
		Result :=  EDTFIO_WORD_SIZE;
    exit
  end;
	if ( strcomp ( str, LONGWRD_STR ) = STRINGS_IDENTICAL ) then
  begin
    result :=  EDTFIO_LONGWRD_SIZE;
    exit
  end;
	Result := EDTFIO_ERROR_READING_FILE
end;

(**************************************************************************
** open_file_for_reading
**
** This routine reads the file header and prepares for reading.
**************************************************************************)
function open_file_for_reading(path: PAnsiChar; var efp: TEdtfio_File_Parameters): integer;
var
  i: integer;
  str1: array [0..4] of AnsiChar;
  str2: array [0..4] of AnsiChar;
  evm_system_type: array [0..9] of AnsiChar;
  data_item_name: array [0..29] of AnsiChar;
  item_id: integer;
  data_item_size: array [0..14] of AnsiChar;
  item_size_value: integer;
  user_segment_count: integer;
begin
	(* open file for reading using specified file name *)
  strcopy( efp.path, path );

  try
	  efp.stream := TFileStream.Create(string(efp.path), fmOpenRead or fmShareDenyNone);
  except
		result := EDTFIO_CANNOT_OPEN_DISK_FILE;
    exit;
  end;
	(* read the file version and recorded time.
		 210 format first line is different than 4000 *)

 	if ( fscanf( efp.stream, '%s ', [@efp.eyedat_version] ) < 1 ) then
  begin
		result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;
	if ( CompareStr(string(efp.eyedat_version), '210' ) = STRINGS_IDENTICAL ) then
  begin
		// read and ignore rest of 210 version info
		if ( fscanf( efp.stream, '%s %s', [@str1, @str2] ) < 2 ) then
    begin
			result := EDTFIO_ERROR_READING_FILE;
      exit
    end;
		// read recorded date from file header
		if ( fscanf( efp.stream,'%s %d, %d ',
								 [@efp.recorded_month,
								 @efp.recorded_day,
								 @efp.recorded_year] ) < 3 ) then
    begin
			result := EDTFIO_NOT_PC_EYEDAT_FILE;
      exit
    end
  end
	else  // non 210 system
  begin
    efp.stream.Seek(LongInt(0), soBeginning);  // rewind to start of file
		// read file version and recorded date
		if ( fscanf( efp.stream, 'EYEDAT %s ',
								 [@efp.eyedat_version] ) = 1) then
      if  ( fscanf( efp.stream, '%s %d, %d ',
								 [@efp.recorded_month,
								 @efp.recorded_day,
								 @efp.recorded_year] ) < 3 ) then
      begin
		  result := EDTFIO_NOT_PC_EYEDAT_FILE;
      exit;
      end;
  end;

	// read recorded time from file header
  efp.stream.Seek(LongInt(38), soBeginning);
	if ( fscanf( efp.stream, '%d:%d:%d.%d ',
							 [@efp.recorded_hour,
							 @efp.recorded_minute,
							 @efp.recorded_second,
							 @efp.recorded_hsecond] ) < 3 ) then
  begin
    // *************** FSCANF HAS A BUG!, CAN'T GET THE HSECOND **********************
		result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;
	// read system type and update rate from file header
  efp.stream.Seek(LongInt(52), soBeginning);
	if ( fscanf( efp.stream, '%s ', [@evm_system_type] ) < 1 ) then
  begin
		result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

  if ( fscanf( efp.stream, '%d Hz ', [@efp.update_rate] ) < 1 ) then
  begin
		result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

	(* convert system type string to numeric id *)
	if CompareStr(string(evm_system_type), 'ETS' ) = STRINGS_IDENTICAL then
		efp.evm_system_type := EDTFIO_MODEL_ETS
	else if CompareStr(string(evm_system_type), 'EYEHEAD' ) = STRINGS_IDENTICAL then
		efp.evm_system_type := EDTFIO_MODEL_EYEHEAD
	else  (* use numeric value of string as id *)
 		efp.evm_system_type := StrToInt(string(evm_system_type));

	// read the number of data items from file header
  efp.stream.Seek(LongInt(72), soBeginning);
	if ( fscanf( efp.stream, '%d DATA ITEMS ', [@efp.number_of_data_items]) < 1 ) then
	begin
		result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;
	// read data item names and corresponding sizes from file header
  for i := 0 to EDTFIO_MAX_DATA_ITEMS_IN_HEADER - 1 do
  begin
		// read data item name
		if ( fscanf( efp.stream, '%s ', [@data_item_name] ) < 1 ) then
    begin
		  result := EDTFIO_ERROR_READING_FILE;
      exit;
    end;
		efp.data_items[ i ][ EDTFIO_ITEM_ID ] := EDTFIO_NO_ITEM;  // preset to no value in case of error
		item_id := convert_item_name_to_id( data_item_name );
		if ( item_id = EDTFIO_ERROR_READING_FILE ) then
		begin
		  result := EDTFIO_ERROR_READING_FILE;
      exit;
    end;
		if ( item_id <> EDTFIO_NO_ITEM ) then  // if item name is not NULL
    begin
			// read size string
			if ( fscanf( efp.stream,'%s ', [@data_item_size] ) < 1 ) then
			begin
		    result := EDTFIO_ERROR_READING_FILE;
        exit;
      end;
			item_size_value := convert_item_size_to_value( data_item_size );
			if ( item_size_value =  EDTFIO_ERROR_READING_FILE ) then
      begin
		    result := EDTFIO_ERROR_READING_FILE;
        exit;
      end;
			efp.data_items[ i ][ EDTFIO_ITEM_ID ] := item_id;
			efp.data_items[ i ][ EDTFIO_ITEM_SIZE ] := item_size_value;
			efp.item_present[ item_id ] := True;
			efp.item_size[ item_id ] := item_size_value;
    end
		else
			efp.item_present[ item_id ] := False;
		end;  // end for

	// read user description from file header
  efp.stream.Seek(LongInt(608), soBeginning);

  if efp.stream.Read(efp.user_description, EDTFIO_USER_DESCRIPTION_SIZE) < EDTFIO_USER_DESCRIPTION_SIZE  then
  begin
    result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

	//efp.user_description[ 199 ] := '\0';  // force zero termination

	// read number of user segments from file header
  efp.stream.Seek(LongInt(808), soBeginning);
	if ( fscanf( efp.stream, '%d USER SEGMENTS', [@efp.number_of_user_segments] ) < 1 ) then
	begin
    result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

	// read number of pseudo segments from file header
  efp.stream.Seek(LongInt(830), soBeginning);
	if ( fscanf( efp.stream, '%d PSEUDO SEGMENTS', [@efp.number_of_pseudo_segments] ) < 1 ) then
	begin
    result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

	// read pseudo segment interval from file header
  efp.stream.Seek(LongInt(852), soBeginning);
	if ( fscanf( efp.stream, '%d MINUTE SEGMENTS', [@efp.max_pseudo_segment_interval] ) < 1 ) then
	begin
    result := EDTFIO_ERROR_READING_FILE;
    exit;
  end;

	// set file pointer to the start of first segment table entry
  efp.stream.Seek(LongInt(874), soBeginning);
	// init segment table
  for i := 0 to EDTFIO_TOTAL_NUMBER_OF_SEGMENTS - 1 do
		efp.segment_table[ i ].segment_type := 0;

	// init segment table index table
  for i := 0 to EDTFIO_TOTAL_NUMBER_OF_SEGMENTS - 1 do
		efp.segment_table_index[ i ] := 0;
	user_segment_count := 0;
	// read segment info from file and create ram resident segment table
  for i := 0 to EDTFIO_TOTAL_NUMBER_OF_SEGMENTS - 1 do
  begin
		efp.stream.Read(efp.segment_table[ i ].segment_type,sizeof(AnsiChar));
		case ( efp.segment_table[ i ].segment_type ) of
			RECORD_USER_SEGMENT :
      begin
        if efp.stream.Read(efp.segment_table[i].disk_file_address, sizeof(LongInt)) < 1 then
				begin
          result := EDTFIO_ERROR_READING_FILE;
          exit;
        end;
        if efp.stream.Read(efp.segment_table[i].starting_time, sizeof(LongInt)) < 1 then
				begin
          result := EDTFIO_ERROR_READING_FILE;
          exit;
        end;
        if efp.stream.Read(efp.segment_table[i].stopping_time, sizeof(LongInt)) < 1 then
				begin
          result := EDTFIO_ERROR_READING_FILE;
          exit;
        end;
				efp.segment_table_index[ user_segment_count ] := i;
				inc(user_segment_count);
				//break;
      end;
			RECORD_PSEUDO_SEGMENT :
      begin
        if efp.stream.Read(efp.segment_table[i].disk_file_address, sizeof(LongInt)) < 1 then
        begin
          result := EDTFIO_ERROR_READING_FILE;
          exit;
        end;
        if efp.stream.Read(efp.segment_table[i].starting_time, sizeof(LongInt)) < 1 then
        begin
          result := EDTFIO_ERROR_READING_FILE;
          exit;
        end;
				//break;
      end;
			else  // eof segment or invalid segment type
				break;  // force exit from for loop
			end  // end switch

		end;  // end for

	(* Initialize the last current segment counter to the first segment.    *)
	efp.last_user_segment_number := 1;

	(* Set the current user and pseudo segment pointers to the correct first user and pseudo segments. *)
	efp.segment_entry_counter := 0;
	efp.pseudo_segment_entry_counter := 1;

	(* Reset the EYEDAT recording in progress flag to zero     *)
	efp.eyedat_recording_flag := 0;

	(* Initialize the internal eyedat double precision clock to zero.   *)
	efp.internal_field_count := 0;

	// Position disk file pointer to the begining of the requested user segment data area.
  efp.stream.Seek(efp.segment_table[ efp.segment_entry_counter ].disk_file_address, soBeginning);
  efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));   // load bit buffer with first 8 bits
  // ********** THIS MAYBE WRONG, should be: if feof( efp -> stream ) != 0 
	if efp.stream.position > efp.stream.size then
     efp.bit_buf := 0;
	efp.bit_cnt := 0;

	//if ( ferror ( efp -> stream ) )
  //  result := EDTFIO_ERROR_READING_FILE;
	//else
	//	return( EDTFIO_NO_ERROR );
  Result := EDTFIO_NO_ERROR;
end;

(*

#define READ( bb ) \
	{ \
	bb = getc( efp -> stream ); \
	if ( feof( efp -> stream ) != 0 ) \
		bb = 0; \
	}

*)


(**************************************************************************
** read_byte
**
** This routine reads one byte ( 8 bits ) from the file.
**************************************************************************)

function read_byte(var efp: TEdtfio_File_Parameters): Shortint;
var
  byte_val: Byte;
begin
	if ( efp.bit_cnt = 0 ) then
	begin
		byte_val := efp.bit_buf;

    efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
  end
	else
  begin
		byte_val := efp.bit_buf shl efp.bit_cnt;
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;

		byte_val := byte_val or ( efp.bit_buf shl ( 8 - efp.bit_cnt ) );
  end;
	result := byte_val;
end;

(**************************************************************************
** read_evmword
**
** This routine reads one evmword ( 10 bits ) from the file.
**************************************************************************)

function read_evmword(var efp: TEdtfio_File_Parameters ): integer;
var
  word_val: word;
begin
	word_val :=  ( efp.bit_buf ) shl ( 2 + efp.bit_cnt );

	efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
  if efp.stream.position > efp.stream.size then
    efp.bit_buf := 0;

	word_val := word_val or (  ( efp.bit_buf ) shl ( 6 - efp.bit_cnt ) );
	efp.bit_cnt := efp.bit_cnt + 2;
	if ( efp.bit_cnt = 8 ) then
  begin
		efp.bit_cnt := 0;
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
  end;
	// return sign extended 10 bit value as 16 bit integer
	result := ( ( word_val and EYEDAT_EVMWORD_MASK ) shl 6 ) shr 6 ;
end;

(**************************************************************************
** read_word
**
** This routine reads one word ( 16 bits ) from the file.
**************************************************************************)

function read_word(var efp: TEdtfio_File_Parameters): integer;
var
  word_val: word;
begin
	if ( efp.bit_cnt = 0 ) then
	begin
		word_val :=  ( efp.bit_buf ) shl 8;
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
		word_val := word_val or efp.bit_buf;
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
  end
	else
  begin
		word_val := ( efp.bit_buf ) shl ( 8 + efp.bit_cnt );
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
		word_val := word_val or ( efp.bit_buf shl efp.bit_cnt );
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
		word_val := word_val or (  efp.bit_buf shl ( 8 - efp.bit_cnt ) );
  end;
	result := word_val;
end;

(**************************************************************************
** read_long_word
**
** This routine reads one long word ( 32 bits ) from the file.
**************************************************************************)

function read_long_word(var efp: TEdtfio_File_Parameters ): Longint;
var
  long_val: Longword;
  i: integer;
begin
	long_val := 0;

  for i := 3 downto 0 do
	begin
		long_val := long_val or (  Longword	(efp.bit_buf)  shl ( i * 8 + efp.bit_cnt ) );
		efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer from file
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;
	end;
	if ( efp.bit_cnt <> 0 ) then
		long_val := long_val or ( Longword(efp.bit_buf) shl ( 8 - efp.bit_cnt ) );
	result := long_val;
end;

(**************************************************************************
** read_data_value
**
** This routine reads the specified number of bits from the file.
**************************************************************************)

function read_data_value(var efp: TEdtfio_File_Parameters; size: Byte): Longint;
begin
	case ( size ) of
		EDTFIO_BYTE_SIZE :
			result := Longint(Byte(read_byte( efp )));
		EDTFIO_EVMWORD_SIZE :
			result := Longint(read_evmword( efp )) ;
		EDTFIO_WORD_SIZE :
			result := Longint(read_word( efp )) ;
		EDTFIO_LONGWRD_SIZE :
			result := Longint(read_long_word( efp )) ;
		else
			result := Longint(0);
  end;
end;

(**************************************************************************
** edtfio_read_field
**
** This routine reads one field from the file.
**************************************************************************)

function edtfio_read_field(var efp: TEdtfio_File_Parameters; var field: TEdtfio_Field): integer;
var
  status_byte: integer;
  overtime_count: Byte;
begin

	field.record_flag := False;
	field.stop_flag := False;
	field.end_of_file_flag := False;

	// Check if user changed segment number since last call to this routine
	if ( field.segment_number <> efp.last_user_segment_number ) then
  begin
		// check if segment number is in valid range
		if ( ( field.segment_number <= 0 ) or ( field.segment_number > ShortInt(EDTFIO_TOTAL_NUMBER_OF_SEGMENTS) ) ) then
    begin
			result := EDTFIO_ILLEGAL_SEGMENT_REQUEST;
      exit;
    end;
		// Set the current user and pseudo segment index values to the correct
		// segment by mapping the specified segment number to an index into
		// the segment table.
		efp.segment_entry_counter := efp.segment_table_index[ field.segment_number - 1 ];
		efp.pseudo_segment_entry_counter := efp.segment_entry_counter + 1;
		(* Check to make sure that the requested segment is a valid one.    *)
		if ( (efp.segment_entry_counter = END_OF_FILE_SEGMENT) or (efp.segment_entry_counter = NULL_SEGMENT) ) then
		begin
			result := EDTFIO_ILLEGAL_SEGMENT_REQUEST;
      exit;
    end;
		// Position disk file pointer to the begining of the requested user segment data area.
    efp.stream.Seek(efp.segment_table[ efp.segment_entry_counter ].disk_file_address, soBeginning);

    efp.stream.Read(efp.bit_buf, sizeof(AnsiChar));  // load bit buffer with first 8 bits
    if efp.stream.position > efp.stream.size then
      efp.bit_buf := 0;

		efp.bit_cnt := 0;
		(* Reset the program record flag found flag.      *)
		efp.eyedat_recording_flag := False;
		(* Set pointer to last requested user segment to the current segment.   *)
		efp.last_user_segment_number := field.segment_number;
		end;

	(* Increment the internal EYEDAT field count *)
	Inc(efp.internal_field_count);

	(* Get the status byte from the buffer and check all flag bits.     *)
	status_byte := read_byte( efp );
	if ( status_byte  and EYEDAT_USER_RECORD_BIT)  <> 0 then // if start of user segment
  begin
		(* Set the return record flag       *)
		field.record_flag := True;
		(* Check for a duplicate record flag by not finding a stop flag.    *)
		if ( efp.eyedat_recording_flag = True ) then
    begin
			result := EDTFIO_DUPLICATE_RECORD_FLAG;
      exit
    end;
		(* Set the program record flag found flag.      *)
		efp.eyedat_recording_flag := True;
		// set the internal EYEDAT clock value to the recorded field count
		efp.internal_field_count := efp.segment_table[ efp.segment_entry_counter ].starting_time;
  end;
	(* Check for a missing record flag by previously not finding a record flag.    *)
	if ( efp.eyedat_recording_flag = False ) then
  begin
		result := EDTFIO_MISSING_RECORD_FLAG;
    exit
  end;
	// Get overtime value if present and put in the return structure. Also
	// save the number of overtimes to increment the internal field count
	// by that number on the next field.
	if  (status_byte and EYEDAT_OVERTIME_BIT) <> 0  then
  begin
		field.overtimes := read_byte( efp );  // read overtime count into current field
		overtime_count := field.overtimes;
  end
	else
  begin
		field.overtimes := 0;  // indicate no overtimes for current field
		overtime_count := 0;
  end;

	if (status_byte and EYEDAT_EXTERNAL_DATA_BIT) <> 0  then  // if xdat value present
  begin
		// read new XDAT value into current field
		field.xdat_value := read_data_value( efp, efp.item_size[ EDTFIO_EXTERNAL_DATA ] );
		// set flag to indicate new xdat value
		field.xdat_flag := True;
  end
	else
		field.xdat_flag := False;  // indicate no xdat value for current field

	if ( status_byte  and EYEDAT_MARK_BIT)  <> 0 then  // if mark value present
	begin
		// read mark value into current field
		field.mark_value := read_data_value( efp, efp.item_size[ EDTFIO_MARK_FLAGS ] );
  end
	else
		field.mark_value := 0;  // indicate no mark value for current field

	if ( efp.item_present[ EDTFIO_SCENE_NUMBER ] = True ) then // if scene number present
		field.scene_number := read_data_value( efp, efp.item_size[ EDTFIO_SCENE_NUMBER ] );
	if ( efp.item_present[ EDTFIO_POG_MAGNITUDE ] = True ) then // if pog magnitude present
		field.point_of_gaze_magnitude := read_data_value( efp, efp.item_size[ EDTFIO_POG_MAGNITUDE ] );
	if ( efp.item_present[ EDTFIO_HORZ_EYE_POSITION ] = True ) then // if horizontal eye position present
		field.horz_eye_pos := read_data_value( efp, efp.item_size[ EDTFIO_HORZ_EYE_POSITION ] );
	if ( efp.item_present[ EDTFIO_VERT_EYE_POSITION ] = True ) then // if vertical eye position present
		field.vert_eye_pos := read_data_value( efp, efp.item_size[ EDTFIO_VERT_EYE_POSITION ] );
	if ( efp.item_present[ EDTFIO_PUPIL_DIAMETER ] = True ) then
		field.pupil_diameter := read_data_value( efp, efp.item_size[ EDTFIO_PUPIL_DIAMETER ] );
	if ( efp.item_present[ EDTFIO_MHT_STATUS ] = True ) then
		field.mht_status := read_data_value( efp, efp.item_size[ EDTFIO_MHT_STATUS ] );
	if ( efp.item_present[ EDTFIO_MHT_X_POSITION ] = True ) then
		field.mht_x_pos := read_data_value( efp, efp.item_size[ EDTFIO_MHT_X_POSITION ] );
	if ( efp.item_present[ EDTFIO_MHT_Y_POSITION ] = True ) then
		field.mht_y_pos := read_data_value( efp, efp.item_size[ EDTFIO_MHT_Y_POSITION ] );
	if ( efp.item_present[ EDTFIO_MHT_Z_POSITION ] = True ) then
		field.mht_z_pos := read_data_value( efp, efp.item_size[ EDTFIO_MHT_Z_POSITION ] );
	if ( efp.item_present[ EDTFIO_MHT_AZIMUTH ] = True ) then
		field.mht_azimuth := read_data_value( efp, efp.item_size[ EDTFIO_MHT_AZIMUTH ] );
	if ( efp.item_present[ EDTFIO_MHT_ELEVATION ] = True ) then
		field.mht_elevation := read_data_value( efp, efp.item_size[ EDTFIO_MHT_ELEVATION ] );
	if ( efp.item_present[ EDTFIO_MHT_ROLL ] = True ) then
		field.mht_roll := read_data_value( efp, efp.item_size[ EDTFIO_MHT_ROLL ] );
	if ( efp.item_present[ EDTFIO_LEFT_PUPIL_DIAMETER ] = True ) then
		field.pupil_diameter := read_data_value( efp, efp.item_size[ EDTFIO_LEFT_PUPIL_DIAMETER ] );
	if ( efp.item_present[ EDTFIO_RIGHT_PUPIL_DIAMETER ] = True ) then
		field.right_pupil_diameter := read_data_value( efp, efp.item_size[ EDTFIO_RIGHT_PUPIL_DIAMETER ] );
	if ( efp.item_present[ EDTFIO_HORZ_EYE_POS_WRT_HD ] = True ) then
		field.horz_eye_pos_wrt_hd := read_data_value( efp, efp.item_size[ EDTFIO_HORZ_EYE_POS_WRT_HD ] );
	if ( efp.item_present[ EDTFIO_VERT_EYE_POS_WRT_HD ] = True ) then
		field.vert_eye_pos_wrt_hd := read_data_value( efp, efp.item_size[ EDTFIO_VERT_EYE_POS_WRT_HD ] );
	if (status_byte  and EYEDAT_STOP_BIT) <> 0 then // if stop flag status set
  begin
		field.stop_flag := True;
		// reset recording flag
		efp.eyedat_recording_flag := False;
		// set current segment pointer to the next segment
		efp.segment_entry_counter := efp.pseudo_segment_entry_counter;
		if ( efp.segment_table[ efp.segment_entry_counter ].segment_type = END_OF_FILE_SEGMENT ) then  // if eof segment
			field.end_of_file_flag := True;
		// increment the current pseudo segment pointer to the next possible pseudo segment
		Inc(efp.pseudo_segment_entry_counter);
  end;
	if (status_byte and EYEDAT_PSEUDO_RECORD_BIT) <> 0 then // if pseudo segment started at this field
  begin
		(* Increment the current pseudo segment pointer to the next segment.   *)
		Inc(efp.pseudo_segment_entry_counter);
  end;
	// set current field count to internal field count value
	field.double_clock := efp.internal_field_count;
	// adjust field count for next field by overtime value
	efp.internal_field_count := efp.internal_field_count + overtime_count;

	{if ( ferror ( efp -> stream ) )
		return( EDTFIO_ERROR_READING_FILE );
	else
  }
  if field.end_of_file_flag = True then
  begin
		result := EDTFIO_END_OF_FILE;
    exit;
  end;
	result := EDTFIO_NO_ERROR;
end;

procedure process_edt_error(szFilename: String; error_code: integer);
begin
	case ( error_code ) of
    EDTFIO_ERROR_READING_FILE :
			raise Exception.Create(Format('Error when reading a file %s.', [szFilename]));

		EDTFIO_CANNOT_OPEN_DISK_FILE :
			raise Exception.Create(Format('Error: Cannot open file %s.', [szFilename]));

		else
			raise Exception.Create(Format('Error: Unknown error code: %d.', [error_code]));
  end;
end;


end.
 