/**
* Name: demotriangles
* Based on the internal empty template. 
* Author: vtwoptwo
* Tags: 
*/


model demotriangles

global {
	bool calibration;
	point camera_vec;
    geometry shape <- rectangle(137.5, 68.5); //, by  each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
    geometry shape2 <- rectangle(124, 62); //137.5, by 68.5 each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
	point correction <- {-79.56895327568054, 10.365369379520416,0}; ///['71.20521068572998','-106.8634033203125']
	point offset_1 <- {0,0,0};
	point offset_2 <- {0,0,0};
	point offset_3 <- {0,0,0};
	point offset_4 <- {0,0,0};
	point offset_5 <- {0,0,0};
	point offset_6 <- {0,0,0};
	point offset_7 <- {0,0,0};
	point offset_8 <- {0,0,0};
	
//	x: 0.7897554039955139
//    y: -0.10731405019760132
//    z: 0.7619441747665405
	
    list<geometry> arena_keystone <- [{0.07481893190277256,0.2588989037851761,0.0},{0.06307093114331902,1.0652565567632335,0.0},{0.8457587439504614,1.0570360089808286,0.0},{0.8424355141560067,0.26338336146736896,0.0}];
    
    //list<geometry> arena_keystone <- [{0.06990871268885124,0.3834149498493714,0.0},{0.0693840701326465,1.050735957897178,0.0},{0.784731733720296,1.1383421587236286,0.0},{0.8101683593216661,0.34381552390748216,0.0}];
    //[{0.06149119403641462,0.3665745384282023,0.0},{0.06026509159250684,1.0649855367920122,0.0},{0.753166038773659,1.1707275653028022,0.0},{0.8101683593216661,0.34381552390748216,0.0}];
    //keystone: 
    //[{0.02852257931437102,0.10360503700533175,0.0},{-0.21260280472398121,1.3188871243727154,0.0},{0.9404558287903739,1.3481995933566604,0.0},{0.8305106960650547,0.16375266332729,0.0}];
    //[{0.11760798505265879,0.11915003216333375,0.0},{-0.0723108271833704,1.3201825406358823,0.0},{1.0407645927319107,1.3119279379879885,0.0},{0.9034625243861722,0.16375266332729022,0.0}];
    //[{0.07832623134128786,0.23560979010275052,0.0},{-0.006373597739283254,1.2593646670452996,0.0},{0.9376499892395613,1.1372383010788627,0.0},{0.871195369551832,0.21421855843437076,0.0}];
    int port <- 9876;
    string url <- "localhost";
    int number_of_agents <- 8; // New variable to specify the number of agents
    int first_agent_port <- 9876; // Starting port for the first agent
	int i <- 0;
	int proximity_graph_distance;
	bool draw_connections<- true;
	graph<simple_agent, simple_agent> proximity_graph;
	bool show_border<- false;
	
    init {
		create simple_agent number:number_of_agents {
		   do connect to: url protocol: "udp_server" port: first_agent_port+i;
		   i<-i+1;
		   self.name <- string(i);
		   write "Initated Agent:";
		   write self.name;
		}
		

    
}
reflex updateProximityGraph when: draw_connections {

		proximity_graph <- graph<simple_agent, simple_agent>(list(simple_agent) as_intersection_graph(proximity_graph_distance));
		
	}


}

species simple_agent skills: [moving, network] {
	
	  
	init {
		
		self.location <- {-500, -500, 0};
	}
	
  float x <- 0.0;
  float y <- 0.0;
  float z <- 0.0;
  float rot <- 50.0;
  point target_location;
  
    
    
   
    reflex fetch when: has_more_message() {
    	
        loop while: has_more_message() {
        	
   
  
	            message msg <- fetch_message();
	            list<string> coords <- msg.contents regex_matches("[-+]?\\d*\\.?\\d+");
	           
                target_location <- {float(coords[0]), float(coords[1]), 1};
                write "coords";
                write coords;
                target_location <- {target_location.x - 78, target_location.y+10, 0};
                write "target_location";
                write target_location;
                
                target_location <- {target_location.x, -target_location.y, 0};
                rot <- float(coords[2])*-100;
                
                if (self.name = string(1)){
                	self.location <- target_location + offset_1;
                
                }
                if (self.name = string(2)){
                	self.location <- target_location + offset_2;
      
                }
                if (self.name = string(3)){
                	self.location <- target_location + offset_3;
      
                }
                if (self.name = string(4)){
                	self.location <- target_location + offset_4;
      
                }
                if (self.name = string(5)){
                	self.location <- target_location + offset_5;
      
                }
                if (self.name = string(6)){
                	self.location <- target_location + offset_6;
      
                }
                if (self.name = string(7)){
                	self.location <- target_location + offset_7;
      
                }
                if (self.name = string(8)){
                	self.location <- target_location + offset_8;
      
                }

        }
        
    }

    aspect default {
    	
	    
        draw triangle(10) at: self.location color: #green rotate: rot;
//        Another way to see the distance between the agents of the same species
//        ask simple_agent at_distance(distance_to_intercept) {
//	    	draw polyline([self.location,myself.location]) color:#black;
	
	
		}
		
   
 
 }
 



grid space cell_width:15.5 cell_height:15.5 {
    aspect dev {
    	if (show_border){
    		draw shape color: #white border: #green width: 1;
    		
    	}
    	else
    	{
        draw shape color: #white border: #white width: 1;
        
        }
    }
}
experiment MainVisualize type: gui virtual: true {
	float minimum_cycle_duration<-0.001;
	parameter "Show Grid" var: show_border <- false category: "Wanna see the grid?" ; 
    parameter "URL" var: url <- "localhost" among: ["10.205.3.55", "127.0.0.1","10.205.3.9", "10.205.3.82", "localhost"] category: "Connection Variables";
    parameter "PORT" var: port <- 9876 among: [9876, 1234,53408] category: "Connection Variables";
    parameter "Number of Agents" var: number_of_agents <- 8 min:0 max:10 category: "Connection Variables";
    parameter "Proximity graph distance" var: proximity_graph_distance <- 100 category: "Connectivity Interaction" min: 1 max:300;
    parameter "Draw connections" var: draw_connections <- true enables:[proximity_graph];
    parameter "Camera" var: camera_vec <- {0,0,0} category: "Camera";
    parameter "Calibration" var: calibration <- false category: "Calibration";
    parameter "offset 1" var: offset_1 <- {0,0,0} category: "Alignment";
    parameter "offset 2" var: offset_2 <- {0,0,0} category: "Alignment";
    parameter "offset 3" var: offset_3 <- {0,0,0} category: "Alignment";
    parameter "offset 4" var: offset_4 <- {0,0,0} category: "Alignment";
    parameter "offset 5" var: offset_5 <- {0,0,0} category: "Alignment";
    parameter "offset 6" var: offset_6 <- {0,0,0} category: "Alignment";
    parameter "offset 7" var: offset_7 <- {0,0,0} category: "Alignment";
    parameter "offset 8" var: offset_8 <- {0,0,0} category: "Alignment";
    
    output {
    	
    	
        display objects_display type: opengl toolbar: false virtual: true {
        	
            species simple_agent position: {0, 0, 0.01};
            
            graphics "proximity_graph" {
            
				if(draw_connections){

					loop eg over: proximity_graph.edges {
						geometry edge_geom <- geometry(eg);
						
						
						draw line(edge_geom.points) color:#green width: 6;
						int edge_distance_in_cms <- round(edge_geom.points[0] distance_to edge_geom.points[1]);
						
						
						point middle_of_the_line <- {((edge_geom.points[0].x+edge_geom.points[1].x)/2),((edge_geom.points[0].y+edge_geom.points[1].y)/2)+5};
						draw(string(edge_distance_in_cms)) color: #green rotate:90 at: middle_of_the_line font:font("SansSerif", 25 , #plain);

						}
					
			
				}
			}
        }
    }
}



experiment Move_Dev parent: MainVisualize type: gui {
  	
    output {
        display objects_display_simulator parent: objects_display fullscreen: 0 
		
        {
            species space position: {0, 0, -0.01} aspect: dev ;
        }
    }
}


experiment Move parent: MainVisualize type: gui {    
    output {
        display objects_display_simulator parent: objects_display fullscreen: 1 keystone: arena_keystone {
        	
        	
            species space position: {0, 0, -0.01} aspect:dev;
        }
    }
}