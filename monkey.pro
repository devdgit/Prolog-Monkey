%The current state is represented by a list of "Actions"

monkey(monkey1).
%monkey(monkey2).
banana(banana1).
%banana(banana2).
box(box1).

loc(loc_init_monkey1).
%loc(loc_init_monkey2).
loc(loc_init_banana1).
%loc(loc_init_banana2).
loc(loc_init_box1).
loc(loc_elsewhere).

writeList([]).
writeList([Head|Tail]) :-
   write(Head), nl,
   writeList(Tail).

% iterative deepening to find the shortest plan that can get the gold and exit the cave
monkey_plan :-
   length(Actions, Length),
   write('Length: '),write(Length),nl,
   valid_possible(Actions),
   goal_state(Actions),
   reverse(Actions, RevActions),
   writeList(RevActions).

valid_possible([]).
valid_possible([Head|Tail]) :-
   valid_possible(Tail),  %must come before
   possible(Head, Tail).  %must come after

possible(go(Monkey, To), Actions) :-
   monkey(Monkey),
   loc(To),
   loc(From),
   location(Monkey, From, Actions),
   \+ From = To,
   \+ on_top_of_box(Monkey, _, Actions). %not on top of any box

possible(push(Monkey, Box, To), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(To),
   loc(From),
   \+ To = From,
   \+ on_top_of_box(Monkey, _, Actions), %not on top of any box
   location(Monkey, From, Actions),
   location(Box, From, Actions).

possible(climb_on(Monkey, Box), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Box, Loc, Actions),
   \+ on_top_of_box(Monkey, _, Actions). %not on top of any box

possible(climb_off(Monkey, Box), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Box, Loc, Actions),
   on_top_of_box(Monkey, Box, Actions). %on top of the same Box

possible(grab(Monkey, Banana), Actions) :-
   monkey(Monkey),
   banana(Banana),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Banana, Loc, Actions),
   on_top_of_box(Monkey, _, Actions), %on top of any box
   \+ has_banana(_, Banana, Actions). %no monkey has the banana

initial_state([]).
goal_state(Actions) :-
   location(monkey1, loc_init_monkey1, Actions),
   %location(monkey2, loc_init_monkey2, Actions),
   location(box1, loc_init_box1, Actions),
   has_banana(monkey1, banana1, Actions).
   %has_banana(monkey2, banana2, Actions).

%Initial Locations
location(Object, Loc, []) :-
   loc(Loc),
   (Object = monkey1, Loc = loc_init_monkey1);
   %(Object = monkey2, Loc = loc_init_monkey2);
   (Object = banana1, Loc = loc_init_banana1);
   %(Object = banana2, Loc = loc_init_banana2);
   (Object = box1,    Loc = loc_init_box1).

%Monkey Locations
location(Monkey, Loc, Actions) :-
   monkey(Monkey),
   loc(Loc),
   Actions = [Head | Tail],
   (   Head = go(Monkey, Loc);
       Head = push(Monkey, _, Loc);
       (   (   Head = climb_on(_, _);
               Head = climb_off(_, _);
               Head = grab(_, _)
	   ),
	   location(Monkey, Loc, Tail)
       )
   ).

%Box Locations
location(Box, Loc, Actions) :-
   box(Box),
   loc(Loc),
   Actions = [Head | Tail],
   (   Head = push(_, Box, Loc);
       (   (   Head = go(_, _);
               Head = climb_on(_, _);
               Head = climb_off(_, _);
               Head = grab(_, _)
	   ),
	   location(Box, Loc, Tail)
       )
   ).

%Banana Locations
location(Banana, Loc, Actions) :-
   banana(Banana),
   monkey(Monkey),
   loc(Loc),
   (   (   has_banana(Monkey, Banana, Actions),
           location(Monkey, Loc, Actions)
       );
       (   \+ has_banana(Monkey, Banana, Actions),
	   Actions = [_ | Tail],
           location(Banana, Loc, Tail)
       )
   ).

% location(Banana, Loc, Actions, AllActions) :-
   % banana(Banana),
   % loc(Loc),
   % Actions = [Head | Tail],
   % (   (   Head = grab(Monkey, Banana),
           % location(Monkey, Loc, AllActions)
       % );
       % (   (   Head = push(_, _, _);
               % Head = go(_, _);
	       % Head = climb_on(_, _);
               % Head = climb_off(_, _)
	   % ),
	   % location(Banana, Loc, Tail, AllActions)
       % )
   % ),
   % possible(Head, Tail).

has_banana(Monkey, Banana, Actions) :-
   monkey(Monkey),
   banana(Banana),
   Actions = [Head | Tail],
   (   Head = grab(Monkey, Banana);
       has_banana(Monkey, Banana, Tail)
   ).

on_top_of_box(Monkey, Box, Actions) :-
   monkey(Monkey),
   box(Box),
   Actions = [Head | Tail],
   (   (   Head = climb_on(Monkey, Box),
           \+ Head = climb_off(Monkey, Box)
       );
       (   Head = grab(_, _),
	   on_top_of_box(Monkey, Box, Tail)
       )
   ).

%****   BEGIN TESTING   ****
%Testing banana location
%   location(banana1,Location,[go(monkey1,loc_elsewhere),climb_off(monkey1,box1),grab(monkey1,banana1),climb_on(monkey1,box1),push(monkey1,box1,loc_init_banana1),go(monkey1,loc_init_box1)]).
%
%Testing correct goal state
%   goal_state([go(monkey1,loc_init_monkey1),push(monkey1,box1,loc_init_box1),climb_off(monkey1,box1),grab(monkey1,banana1),climb_on(monkey1,box1),push(monkey1,box1,loc_init_banana1),go(monkey1,loc_init_box1)]).
%
%current error: (2013.09.21 01:49 AM)
%valid_possible([Act2,Act1])=valid_possible([A,go(monkey1,loc_init_box1)])
%
%**** END TESTING ****
