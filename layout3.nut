 

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below"; 
   </ label="Select listbox, vert_wheel", help="Select wheel type or listbox", options="listbox, vert_wheel", order=2 /> enable_list_type="vert_wheel";
   </ label="Select spinwheel art", help="The artwork to spin", options="marquee, wheel", order=3 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=4 /> transition_ms="35";  
</ label="--------   Pointer images    --------", help="Change pointer image", order=5 /> uct4="select below";
   </ label="Select pointer", help="Select animated pointer", options="default,emulator,rocket,hand,none", order=6 /> enable_pointer="default";  
</ label="--------    Miscellaneous    --------", help="Miscellaneous options", order=7 /> uct6="select below";
   </ label="Enable monitor static effect", help="Show static effect when snap is null", options="Yes,No", order=8 /> enable_static="No";
   </ label="Enable box art", help="Select box art", options="Yes,No", order=9 /> enable_gboxart="Yes";    
   </ label="Enable fan art", help="Select fan art", options="Yes,No", order=10 /> enable_gfanart="Yes"; 
}  

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.layout.font="Roboto";

// modules
fe.load_module( "fade" );


//Background
//local bg = fe.add_image( "backgrounds/bg_blue.png", 0, 0, flw, flh );

// Box art to dipslay, uses the emulator.cfg path for boxart image location
if ( my_config["enable_gboxart"] == "Yes" )
{
local boxart = fe.add_artwork("boxart", flx*0.0, fly*0.0 flw*1, flh*1 );
}


/////////////////////
//Video
/////////////////////

//create surface for snap
local surface_snap = fe.add_surface( 1920, 1080 );
local snap = FadeArt("snap", 0, 0, 1920, 1080, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = false;

//now position and pinch surface of snap
//adjust the below values for the game video preview snap
surface_snap.set_pos(0, 0, 1920, 1080 );
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;

/////////////////////
// The following section sets up what type and wheel and displays the users choice
//listbox
if ( my_config["enable_list_type"] == "listbox" )
{
local sort_listbox = fe.add_listbox( 0, 96, 45, 202 );
sort_listbox.rows = 13;
sort_listbox.charsize = 10;
sort_listbox.set_rgb( 0, 0, 0 );
sort_listbox.format_string = "[SortValue]";
sort_listbox.bg_alpha=255;
sort_listbox.visible = false;

local listbox = fe.add_listbox(flx*0.56, fly*0.12, flw*0.41, flh*0.8 );
listbox.rows = 13;
listbox.charsize = 18;
listbox.set_rgb( 255, 255, 255 );
listbox.bg_alpha = 90;
listbox.align = Align.Left;
listbox.selbg_alpha = 90;
listbox.sel_red = 255;
listbox.sel_green = 255;
listbox.sel_blue = 0;
}

/////////////////////
//Wheel Vert
/////////////////////

if ( my_config["enable_list_type"] == "vert_wheel" )
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.02, flx* 0.02, flx* 0.02, flx* 0.02, flx* 0.02, flx* 0.02, flx* 0.01, flx* 0.02, flx* 0.02, flx* 0.02, flx* 0.02, flx* 0.02, ]; 
	local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.440, fly*0.565, fly*0.680 fly*0.795, fly*0.910, fly*0.99, ];
	local wheel_w = [  336,  336,  336,  336,  336,  336, 380,  336,  336,  336,  336,  336, ];
	local wheel_a = [  150,  150,  150,  150,  150,  150, 235,  150,  150,  150,  150,  150, ];
	local wheel_h = [  116,  116,  116,  116,  116,  116, 140,  116,  116,  116,  116,  116, ];
	local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];

local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 90;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}



/////////////////////
// Video Preview or static video if none available
// remember to make both sections the same dimensions and size
/////////////////////
if ( my_config["enable_static"] == "Yes" )
{
//adjust the values below for the static preview video snap
   const SNAPBG_ALPHA = 75;
   local snapbg=null;
   snapbg = fe.add_image( "static.mp4", 345, -0.009, 1550, 1100 );
   snapbg.trigger = Transition.EndNavigation;
   snapbg.skew_y = 0;
   snapbg.skew_x = 0;
   snapbg.pinch_y = 0;
   snapbg.pinch_x = 0;-
   snapbg.rotation = 0;
   snapbg.set_rgb( 155, 155, 155 );
   snapbg.alpha = SNAPBG_ALPHA;
}
 else
 {
 local temp = fe.add_text("", flx*0, fly*0, flw*1, flh*1 );
 temp.bg_alpha = SNAPBG_ALPHA;
 }



// Fan art to display, uses the emulator.cfg path for fanart for fanart image location
if ( my_config["enable_gfanart"] == "Yes" )
::OBJECTS <- {
fanart = fe.add_artwork("fanart", flx*0.0, fly*0.0, flw*1, flh*1 ),
}
	
/////////////////////
//  special art
/////////////////////
local next = fe.add_image("nextsystem.swf", 550, 950, 320, 110);
local prev = fe.add_image("previoussystem.swf", 1000, 950, 380, 110);
local freeplay = fe.add_image("freeplay.swf", 1475, 985, 0, 0);
//local pressstart = fe.add_image("pressstart.swf", 550, 35, 0, 0);

//fe.add_transition_callback( "fade_transitions" );
