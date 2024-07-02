/**
* Name: hockey
* Air Hockey Game
 
* Author: fheshiki
* Tags: 
*/

model hockey

global {
	// REAL-WORLD DIMENSIONS FOR LAB SET-UP
	geometry shape <- rectangle(137.5, 68.5); //, by  each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
    // geometry shape <- rectangle(124, 62); //137.5, by 68.5 each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
	point correction <- {-79.56895327568054, 10.365369379520416,0}; ///['71.20521068572998','-106.8634033203125'];
	list<geometry> arena_keystone <- [{0.07481893190277256,0.2588989037851761,0.0},{0.06307093114331902,1.0652565567632335,0.0},{0.8457587439504614,1.0570360089808286,0.0},{0.8424355141560067,0.26338336146736896,0.0}];
	float grid_width <- shape.width;
	float grid_height <- shape.height;
	
	
	// AGENT PORT VARIABLES 
	int port <- 9876;
    string url <- "localhost";
    int nb_players <- 2; // New variable to specify the number of agents
    int first_agent_port <- 9876; // Starting port for the first agent
	int i;
	
	// DISPLAY OPTIONS
	bool show_puck;
	string show_board;
	bool show_border;
	
	// GAME VARIABLES
	bool game_start <- true;
	bool slow;
	int p1_score <- 0;
	int p2_score <- 0;
	
	float base_speed;
	float collision_radius;
    
    geometry goal1 <- rectangle(7, 22) at_location {0, grid_height / 2};
    geometry goal2 <- rectangle(7, 22) at_location {grid_width, grid_height / 2};

	init {
		i <- 0;
		create player number: nb_players {
		   do connect to: url protocol: "udp_server" port: first_agent_port+i;
		   i<-i+1;
		   self.name <- string(i);
		   self.id <- i;
		   self.color <- rnd_color(255);
		   write "Initated Agent:";
		   write self.name;
		}
		create puck;
    }
}

species game_object parallel: true skills: [moving, network] {
	float x <- 0.0;
	float y <- 0.0;
	float z <- 0.0;
	float rot <- 50.0;
	
	point target_location;
	int size <- 5;
	rgb color;
	int id;
	
	bool is_within_grid(point pos) {
        return pos.x >= 0 and pos.x <= grid_width and pos.y >= 0 and pos.y <= grid_height;
    }
    
    bool is_within_side(point pos) {
        if (even(id)) {
            return pos.x <= grid_width / 2;
        } else {
            return pos.x >= grid_width / 2;
        }
    }
	
	aspect default {
        draw circle(size) at: self.location color: color rotate: rot;
	}
}

species player parent: game_object {
	rgb color;
	int size <- 3;
	
	reflex fetch when: has_more_message() {
    	loop while: has_more_message() {
	        message msg <- fetch_message();
	        list<string> coords <- msg.contents regex_matches("[-+]?\\d*\\.?\\d+");
	       
	        target_location <- {float(coords[0]), float(coords[1]), 1};
	        target_location <- {target_location.x - 78, target_location.y+10, 0};
            target_location <- {target_location.x, -target_location.y, 0};
            rot <- float(coords[2]) * -100;
           
			
			if (is_within_grid(target_location) and is_within_side(target_location)) {
                self.location <- target_location;
            }	
        }
    }
}

species puck parent: game_object {
	rgb color <- #blue;
	int size <- 3;

    float speed <- base_speed;
    float direction_x <- rnd(-1.0, 1.0);
    float direction_y <- rnd(-1.0, 1.0);
    
    init {
        self.location <- {grid_width / 2, grid_height / 2, 0};
    }

    reflex init {
        float magnitude <- sqrt(direction_x * direction_x + direction_y * direction_y);
        direction_x <- direction_x / magnitude;
        direction_y <- direction_y / magnitude;
    }

    reflex move when: game_start and every(0.1#s) {
        float new_x <- self.location.x + direction_x * speed;
        float new_y <- self.location.y + direction_y * speed;

        if (new_x < 0 or new_x > grid_width) {
            direction_x <- -direction_x;
            new_x <- self.location.x + direction_x * speed;
        }
        if (new_y < 0 or new_y > grid_height) {
            direction_y <- -direction_y;
            new_y <- self.location.y + direction_y * speed;
        }
        
        self.location <- {new_x, new_y, self.location.z};
        
        do check_goal;
    }
    
    reflex player_collision {
    	ask player {
            if ((self.location distance_to myself.location) <= collision_radius + myself.size) {
				float dx <- myself.location.x - self.location.x;
				float dy <- myself.location.y - self.location.y;
				float magnitude <- sqrt(dx * dx + dy * dy);
				
				myself.direction_x <- dx / magnitude;
				myself.direction_y <- dy / magnitude;
				myself.location <- myself.location + {myself.direction_x, myself.direction_y, 0} * 0.1;
				
				if (myself.speed < base_speed * 1.5) {
					myself.speed <- myself.speed + 0.05;
				}
            }
            else if ((myself.speed > base_speed * 2) and slow) {
            	myself.speed <- myself.speed - 0.001;
            }
        }
    }
    
    action check_goal {
        if (self.location distance_to goal1 <= 2) {
            p2_score <- p2_score + 1;
            do reset_puck;
        } else if (self.location distance_to goal2 <= 2) {
            p1_score <- p1_score + 1;
            do reset_puck;
        }
    }
    
    action reset_puck {
        self.location <- {grid_width / 2, grid_height / 2, 0};
        direction_x <- rnd(-1.0, 1.0);
        direction_y <- rnd(-1.0, 1.0);
        float magnitude <- sqrt(direction_x * direction_x + direction_y * direction_y);
        direction_x <- direction_x / magnitude;
        direction_y <- direction_y / magnitude;
        speed <- base_speed;
    }
	
	aspect default {
		if (show_puck) {
			draw circle(size) color: color rotate: rot;
		}
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

experiment hockey type: gui virtual: true{
	// EXPERIMENT VARIABLES
	float minimum_cycle_duration<-0.00001;
	
	// EXPERIMENT PARAMETERS 
    parameter "URL" var: url <- "localhost" among: ["10.205.3.55", "127.0.0.1","10.205.3.9", "10.205.3.82", "localhost"] category: "Connection Variables";
    parameter "PORT" var: port <- 9876 among: [9876, 1234,53408] category: "Connection Variables";
    parameter "Number of Players" var: nb_players <- 2 min:0 max:10 category: "Connection Variables";
    
    parameter "Show Grid" var: show_border <- false category: "Display Options";
    parameter "Puck" var: show_puck <- true category: "Display Options";
    parameter "Board" var: show_board <- "../images/game.jpg" among: ["../images/", "../images/example.jpg", "../images/game.jpg"] category: "Display Options";
    
    parameter "Puck Speed" var: base_speed <- 0.5 min: 0.01 max: 2.0 category: "Game Options";
    parameter "De-acceleration" var: slow <- false category: "Game Options";
    parameter "Collision Radius" var: collision_radius <- 3.5 min: 0.01 max: 10.0 category: "Game Options";
    
    
	output {
		display default type: opengl toolbar: false fullscreen: 1 keystone:arena_keystone virtual: true {
			species puck position: {0, 0, 0.01};
            species player position: {0, 0, 0.01};                  
		}
	}
}

experiment Main parent: hockey type: gui {
	output{
		monitor main value: cycle refresh: every(1#cycle);
		
		display main_display parent: default fullscreen: 0 {
			species space position: {0, 0, -0.01} aspect: dev;
			
			image_layer show_board;
			graphics game {
            	draw string(p1_score) + " : " + string(p2_score) at: {64 ,8} font:font("Arial", 70, #bold+#italic) color:#black;
//            	draw goal1 color: #black;
//            	draw goal2 color: #blue;
            }
		}
	}
}
