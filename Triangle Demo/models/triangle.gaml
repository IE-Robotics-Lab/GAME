/**
* Name: triangle
* Based on the internal empty template. 
* Author: fheshiki
* Tags:  
*/

model triangle

global {
	// REAL-WORLD DIMENSIONS FOR LAB SET-UP
	geometry shape <- rectangle(137.5, 68.5); //, by  each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
	point correction <- {-38.33982050418854, 72.43500351905823, 0}; // Previous Calibration: ['71.20521068572998','-106.8634033203125']
    list<geometry> arena_keystone <- [{0.0736697534742366,0.23169516447101535,0.0},{0.0675060826301559,1.0367573972528539,0.0},{0.8445979162363061,1.011437353862544,0.0},{0.8474850121913879,0.23125704030401106,0.0}];
    float grid_width <- shape.width;
    float grid_height <- shape.height;
    
    // CONNECTION VARIABLES
	int port <- 9876;
    string url <- "localhost";
    int number_of_agents <- 10;
    int base_id <- 0;
	
	// DISPLAY VARIABLES
	int screen <- 1;
	bool show_border<- false;
	bool draw_connections<- true;
	
	// OFFSET VARIABLES -0.5, -1.5, -2.0, -4.5
	float x_offset_min <- -0.5;
	float x_offset_max <- -1.5;
	float y_offset_min <- -2.0;
	float y_offset_max <- -4.5;
	
	// MODEL VARIABLES
	int proximity_graph_distance <- 100;
	graph<simple_agent, simple_agent> proximity_graph;
	
    init {
		create simple_agent number: number_of_agents {
		   do connect to: url protocol: "udp_server" port: port + base_id;
		   base_id <- base_id + 1;
		   self.name <- string(base_id);
		}
	}
	
	reflex updateProximityGraph when: draw_connections {
		proximity_graph <- graph<simple_agent, simple_agent>(list(simple_agent) as_intersection_graph(proximity_graph_distance));
	}
}

species simple_agent skills: [moving, network] {
	float rot;
	point target_location;
	point offset;
	
	init {
		self.location <- {-500, -500, -500};
	}
	
	reflex fetch when: has_more_message() {
        loop while: has_more_message() {
            message msg <- fetch_message();

            list<string> coords <- msg.contents regex_matches("[-+]?\\d*\\.?\\d+");
           
            target_location <- {float(coords[1]) + correction.y, float(coords[0]) - correction.x, 0};
            rot <- float(coords[3]) * -100;
 			
 			self.location <- target_location;
        }
    }

	action calculate_offset {
    	float offset_x;
    	
    	if (self.location.x >= 0) {
        	offset_x <- x_offset_min + (self.location.x / grid_width) * (x_offset_max - x_offset_min);
    	} else {
        	offset_x <- x_offset_min + (self.location.x / -grid_width) * (x_offset_max - x_offset_min);
    	}

    	float offset_y;
    	if (self.location.y >= 0) {
        	offset_y <- y_offset_min + (self.location.y / grid_height) * (y_offset_max - y_offset_min);
    	} else {
        	offset_y <- y_offset_min + (self.location.y / -grid_height) * (y_offset_max - y_offset_min);
    	}
   	 
    	return {offset_x, offset_y, 0};
	}

	aspect default {
    	offset <- calculate_offset();
   	 
//    	draw circle(4) at: (self.location + offset) color: #green rotate: rot anchor: #center;
    	draw circle(4) at: (self.location) color: #green rotate: rot anchor: #center;
	}

}

grid space cell_width: 15.5 cell_height: 15.5 schedules:[] {
    aspect dev {
    	if (show_border){
    		draw shape color: #white border: #green width: 1;
    	} else {
        	draw shape color: #white border: #white width: 1;
        }
    }
}

experiment MainVisualize type: gui virtual: true {
	// Connection Parameters
    parameter "URL" var: url <- url among: ["10.205.3.55", "127.0.0.1", "10.205.3.9", "10.205.3.82", "localhost"] category: "Connection Variables";
    parameter "PORT" var: port <- port among: [9876, 1234, 53408] category: "Connection Variables";
    parameter "Number of Agents" var: number_of_agents <- number_of_agents min: 0 max: 10 category: "Connection Variables";
    parameter "Base ID" var: base_id <- base_id min: 0 max: 10 category: "Connection Variables";
    
    // Display Parameters
    parameter "Show Grid" var: show_border <- show_border category: "Display";
    parameter "Fullscreen" var: screen <- screen among: [0, 1] category: "Display" ;  
    parameter "Draw Connections" var: draw_connections <- draw_connections enables: [proximity_graph] category: "Display";
    parameter "Correction" var: correction <- correction category: "Display";
    
    // Offset Parameters
    parameter "X Offset Minimum" var: x_offset_min <- x_offset_min category: "Offset";
    parameter "X Offset Maximum" var: x_offset_max <- x_offset_max category: "Offset";
    parameter "Y Offset Minimum" var: y_offset_min <- y_offset_min category: "Offset";
    parameter "Y Offset Maximum" var: y_offset_max <- y_offset_max category: "Offset";
    
    // Demo Parameters
    parameter "Proximity Distance" var: proximity_graph_distance <- proximity_graph_distance min: 1 max: 300;
 	
    
    output {
        display objects_display type: opengl toolbar: false virtual: true {
            species simple_agent position: {0, 0, 0.01};
            
            graphics "proximity_graph" {
				if (draw_connections){
					loop eg over: proximity_graph.edges {
						point offset <- eg.offset;

						geometry edge_geom <- geometry(eg);
						list<point> eg_points <- [edge_geom.points[0] + offset, edge_geom.points[1] + offset];
						
						int edge_distance_in_cms <- round(eg_points[0] distance_to eg_points[1]);
						
						if (edge_distance_in_cms < proximity_graph_distance) {
							point middle_of_the_line <- {((eg_points[0].x + eg_points[1].x) / 2),((eg_points[0].y + eg_points[1].y) / 2) + 5};
							
							draw line(eg_points) color:#green width: 6;							
							draw(string(edge_distance_in_cms)) color: #green rotate: 90 at: middle_of_the_line font: font("SansSerif", 25, #plain);
						} 
					}
				}
			}

        }
    }
}

experiment Main parent: MainVisualize type: gui {    
    output {
        display objects_display_simulator parent: objects_display fullscreen: screen keystone: arena_keystone {
            species space position: {0, 0, -0.01} aspect: dev refresh: false;
        }
    }
}

experiment Benchmarking parent: Main type: gui benchmark: true {}
