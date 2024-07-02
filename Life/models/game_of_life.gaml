/**
* Name: gameoflife
* GAMA Simulation of Conway's Game of Life 
* Author: fheshiki
* Tags: 
*/

model gameoflife

global torus: torus_env {
	int env_width <- 200 min: 10 max: 1000;
	int env_height <- 200 min: 10 max: 1000;
	
	bool torus_env <- true;
	bool parallel <- true;
	
	int density <- 25 min: 1 max: 99;
	geometry shape <- rectangle(env_width, env_height);
	
	rgb livingcolor <- #white;
	rgb deadcolor <- #black;
	rgb emergingcolor <- #green;
	rgb dyingcolor <- #red;
	
	//Conditions to live
	list<int> living_conditions <- [2, 3];
	//Conditions to birth
	list<int> birth_conditions <- [3];
	
	init {
		do description;
	}
	
	reflex generation {
		ask life_cell parallel: parallel {
			do evolve;
		}
	}
	
	action description {
		write "Game of Life";
	}
}

grid life_cell width: env_width height: env_height neighbors: 8 
use_individual_shapes: false use_regular_agents: false use_neighbors_cache: false parallel: parallel {
	bool new_state;
	list<life_cell> neighbors <- self neighbors_at 1;
	
	bool alive <- (rnd(100)) < density;
	rgb color <- alive ? livingcolor : deadcolor;
	
	action evolve {
		int living <- neighbors count each.alive;
		
		if alive {
			new_state <- living in living_conditions;
			color <- new_state ? livingcolor : dyingcolor;
		}
		else {
			new_state <- living in birth_conditions;
			color <- new_state ? emergingcolor : deadcolor;
		}
	}
	
	reflex update {
		alive <- new_state;
	}
}

experiment "Game of Life" type: gui {
	parameter "Run in parallel " var: parallel category: 'Board';
	parameter 'Width:' var: env_width category: 'Board';
	parameter 'Height:' var: env_height category: 'Board';
	parameter 'Torus?:' var: torus_env category: 'Board';
	parameter 'Initial density of live cells:' var: density category: 'Cells';
	parameter 'Numbers of live neighbours required to stay alive:' var: living_conditions category: 'Cells';
	parameter 'Numbers of live neighbours required to become alive:' var: birth_conditions category: 'Cells';
	parameter 'Color of live cells:' var: livingcolor category: 'Colors';
	parameter 'Color of dying cells:' var: dyingcolor category: 'Colors';
	parameter 'Color of emerging cells:' var: emergingcolor category: 'Colors';
	parameter 'Color of dead cells:' var: deadcolor category: 'Colors';
	output {
		display Life type: 3d axes:false antialias:false{
			grid life_cell;
		}

	}

}

//species cell {
//	bool status <- false;
//	int neighbors; 
//	rgb color;
//	life my_cell <- one_of(life);
//
//	init {
//		location <- my_cell.location;
//		neighbors <- length(my_cell.neighbors);
//	}
//	
//	reflex die when: status and ((neighbors < 2) or (neighbors > 3)){
//		status <- false;
//	}
//	
//	reflex live when: status and ((neighbors = 2) or (neighbors = 3)) {
//		status <- true;
//	}
//	
//	reflex reproduce when: !status and (neighbors = 3) {
//		status <- true;
//	}
//	
//	reflex change_color {
//		if (status) {
//			color <- #white;
//		}
//		else {
//			color <- #black;
//		}
//	}
//	
//	aspect default {
//		draw square(cell_size) at: self.location color: color;
//	}
//}
//
//
//grid life width: 50 height: 50 {
//	list<life> neighbors <- (self neighbors_at 1);
//	rgb color <- rgb(0,0,0);
//}

//experiment gameoflife type: gui {
//	parameter "Initial Number of Cells: " var: nb_cells min: 1 max: 100 category: "Cells";
//	output {
//		display main_display {
//			grid life border: #white;
//			species cell aspect: default;
//		}
//	}
//}
