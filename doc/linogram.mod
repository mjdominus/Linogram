



TUTORIAL INTRODUCTION

Linogram is a system for specifying and drawing diagrams.  It is
explained in detail in chapter 9 of _Higher-Order Perl_, by Mark Jason
Dominus.  See http://hop.perl.plover.com/ for complete details.

A linogram program is a file, or a series of files, that define the
shapes that are to be drawn and their relationships to one another.
Each object to be drawn is called a "feature" and is an instance of a
"type".  The type has the definition of what the feature looks like
and how it behaves.

Initially, linogram knows only one type, called "number", which is
simply a number.  Other types are built from this.  For example, a
point has an x and a y coordinate, so its definition is simply

        define point {
          number x, y;
        }

A line is determined by two points, called the "start" and the "end",
so it could be defined like this:

        define line {
          point start, end;
        }

But in fact the definition in linogram's standard library is a little
more interesting:

        define line {
          point start, end, center;
          constraints {
            center = (start + end)/2;
          }
        }

This says that a line has three named points, and that the center
point is halfway between the start and the end points.  Linogram can
use this definition to compute the center if it knows the start or the
end point, or it can compute the start if all it knows is the center
and the end.  Any two of the points determine the third.

How do we include a line in a diagram?  The input file that you give
to linogram defines a type, called the "root type".   The definition
of the root type is just like any other type, edxcept that you omit
the "define ... {" at the beginning.  So you can say

        line base, side1, side2;

and your diagram will contain three lines.  You can constrain the
positions of the lines and get a triangle:

        side1.start = side2.start;
        base.start  = side1.end;
        base.end    = side2.end;

Since side1, side2, and base are lines, each has a start, and end, and
a center point already defined.  The center of the base is a point
called base.center.  And since points are defined as having x and y
coordinates, we can refer to the coordinates of the center of the base
as "center.base.x" and "center.base.y".

We could force the center of the base to be located in a certain place
by putting in a constraint:

        center.base.x = 3;
        center.base.y = 4;

which we may abbreviate to 

        center.base = (3, 4);

We can constrain the base to be horizontal:

        base.start.y = base.end.y;

We can also constrain the triangle to be isosceles by requiring the
intersection of side1 and side2 to be located directly above the
midpoint of the base:

        side1.start.x = base.center.x;

We don't have to mention side2 here because linogram already knows
that side2.start.x = side1.start.x.  We could put that constraint in,
if we wanted, but linogram would recognize that it was redundant, and
ignore it.

Similarly, once we've said that

        base.start.y = base.end.y;

we don't have to explicitly require that

        base.start.y = base.center.y;

Linogram knows from the definition of "line" that

        center.y = (start.y + end.y)/2;

for all lines, including "base", and so if start.y is the same as
end.y, it can figure out that center.y is the same also.

If you're going to have a lot of triangles of this sort, it makes
sense to wrap all this up in your own type definitions:

        define triangle {
            line base, side1, side2;
            constraints { 
                side1.start = side2.start;
                base.start  = side1.end;
                base.end    = side2.end;
                base.start.y = base.end.y;
                side1.start.x = base.center.x;
            }
        }

Now you can say

        triangle T1, T2;

to make two triangles, each with its own side1, side2, and base.  Each
triangle contains three sides, each of which has two points, each of
which has two coordinates, so the triangle is ultimately defined by 12
numbers:

        The x and y coordinates of the apex
        The x and y coordinates of the lower left vertex
        The x and y coordinates of the lower right vertex
        The x and y coordinates of the middle of the left side
        The x and y coordinates of the middle of the right side
        The x and y coordinates of the middle of the base

But not all the numbers are required, because the constraints relate
the numbers to each other.  In fact, only 4 numbers are required to
define the location of each of these triangles: you need the y
coordinate of the apex, the two x coordinates of the two base
vertices, and the single shared y coordinate of the two base vertices,
and linogram will figure everything else out.  


        T1.base.start  = (5,3)
        T1.base.end    = (9,3)
        T1.side1.start = (7,5)

Here we specified six numbers, but two of them are redundant.
Once linogram knows that T1.base.start.y is 3, it will figure out that
T1.base.end.y is also 3 without our having to say so; if the
y-coordinates in the first two lines didn't match, linogram would
complain that we were violating a constraint.  And we said explicitly
that T1.side1.start.x is 7, but linogram can figure that out too.  It
knows that T1.base.center.x = (T1.base.start.x + T1.base.start.y)/2 = 
(5 + 9)/2 = 7, and it also knows that T1.side1.start.x =
T1.base.center.x, so is also 7.  Again, it doesn't matter that we gave
linogram this redundant information, but it will check it for us.

Having to say "T1.side1.start" to locate the apex is a little
annoying.  We can easily add an alias to the triangle:

        define triangle {
            line base, side1, side2;
*           point apex;
            constraints { 
*               apex = side1.start = side2.start;
                base.start  = side1.end;
                base.end    = side2.end;
                base.start.y = base.end.y;
*               apex.x = base.center.x;
            }
        }

Now instead of saying

        T1.side1.start = (7,1)

we can say

        T1.apex = (7,1)

and since apex is defined to be equal to side1.start, these are
equivalent.  

We can also add aliases for the length of the base and the altitude of
the triangle if we think that will be convenient:

        define triangle {
            line base, side1, side2;
*           number wd, ht;
            point apex;
            constraints { 
                apex = side1.start = side2.start;
                base.start  = side1.end;
                base.end    = side2.end;
                base.start.y = base.end.y;
*               ht = apex.y - base.center.y;
*               wd = base.end.x - base.start.x;
                apex.x = base.center.x;
            }
        }

and now we can define a particular triangle:

        triangle T1;
        constraints {
          T1.base.center = (7, 3);
          T1.wd = 4;
          T1.ht = 2;
        }

and we have a triangle whose base is at (7, 3) with a width of 4 and a
height of 2; linogram figures out where everything else goes.

One final abbrviation might be convenient.  We can define a reference
point in the triangle and use it to specify the location of the
triangle itself instead of the location of the center of the
triangle's base.  We might put the reference point in the middle of
the triangle, or at the apex, or in the middle of the base, or
wherever seems convenient:

        define triangle {
            line base, side1, side2;
            number wd, ht;
*           point loc;
*           number x, y;
            point apex;
            constraints { 
                apex = side1.start = side2.start;
                base.start  = side1.end;
                base.end    = side2.end;
                base.start.y = base.end.y;
                ht = apex.y - base.center.y;
                wd = base.end.x - base.start.x;
                apex.x = base.center.x;
*               (x, y) = loc = base.center;
            }
        }

Here I've put the reference point in the middle of the base. Now
instead of locating T1.base.center explicitly, we can just locate
T1.loc, and we can also ask about T1.x and T1.y to get the coordinates
of this reference point.

There's also a shorthand notation for this:

        triangle T1;
        constraints {
          T1.loc = (7, 3);
          T1.wd = 4;
          T1.ht = 2;
        }

If you prefer, you can write it like this:

        triangle T1(wd=4, ht=2, loc=(7,3));

which might look nicer.


Now maybe we want two triangles connected by an arrow:

        triangle T1(wd=4, ht=2, loc=(7,3)), T2;
        arrow a(start = T1.side2.center, end = T2.side1.center);


        constraints {
          T2 = T1 + (3, 0);
        }

arrows are just like lines---they have a start and and end
point---except they're drawn with arrowheads at the end point.  Here
we've required that the arrow "a" goes from the right side of T1 to
the left side of T2.  And T1 is clearly located.  But where is T2?
And how big is it?

The constraints say that triangle T2 is exactly the same size and
shape as T1, but three units due east.  If we had written

        T2 = T1 + (3, 1)

it would have been three units east and one unit north.  If we change
the 0 to a 1 in this way, we don't have to worry about the fact that
the arrow, which used to be horizontal, is now diagonal.  The arrow is
constrained to go from one triangle to the other, and linogram will
figure out what it must look like in order for that to be true, and
draw it properly.

Suppose we're going to draw a diagram that talks about process
management, and each triangle represents a process.  We'll have lot of
these four-by-two triangles.  It would get annoying to ask for a lot
of triangles that all have wd=4 and ht=2.  We should make a new type
with a logical name:

        define process extends triangle {
          point start, end;
          constraints { wd = 4; ht = 2;
                        start = side1.center; end = side2.center; }
        }

This defines a new type that has all the same numbers, lines, and
points that a triangle has, and all the same constraints, and some
additional ones as well.  In particular, wd and ht have been
constrained to be 4 and 2, so every "process" is a triangle of a
specific size.

Now instead of this:

        triangle T1(wd=4, ht=2, loc=(7,3)), T2;
        arrow a(start = T1.side2.center, end = T2.side1.center);

        constraints {
          T2 = T1 + (3, 0);
        }

we can write this:

        process P1(loc=(7,3)), P2;
        arrow a(start = P1.end, end = P1.start);

        constraints {
          P2 = P1 + (3, 0);
        }

Or we could have a whole string of processes:

        number xspc = 0.75;
        process P1(loc=(0,0)), 
                P2 = P1 + (xspc, 0), 
                P3 = P2 + (xspc, 0),
                P4 = P3 + (xspc * 1.5, 0),
                P5 = P4 + (xspc, xspc * -0.25);
        arrow a12(start=P1.end, end=P2.start),
              a23(start=P2.end, end=P3.start),
              a34(start=P3.end, end=P4.start),
              a45(start=P4.end, end=P5.start);

If an assembly like this is going to be common, we could define a new
type to represent it; the type would include five processes and four
arrows. 

----------------------------------------------------------------

REFERENCE MANUAL

The basic linogram object is called a "feature".  A feature contains
some instructions about how it should be drawn, a list of subfeatures
that it contains, their names, and a list of constraints on the
subfeatures.  

A linogram file is a essentially a definition of a single feature
called the "root feature".  The subfeatures of the root feature are
the boxes and arrows that make it up.   You tell linogram what boxes
and arrows are included in the root feature, and how they are related
to one another, just as you would tel it about any other type, such as
the triangles in the tutorial.

There are just a few things that can appear in a definition:

* "require" declarations

  A declaration like

        require "foo";

  tells linogram to pause what it is doing, locate "foo.lino"
  somewhere, and read it in.  Then it picks up where it left off.
  Often, "foo" is be a standard linogram library file.  For example,
  linogram has a standard definition of a "box" that you can load in
  by saying

        require "box";

  after which you may declare features to have type "box":

        box a, b;


  But you can also require a file that contains definitions that you
  wrote yourself.

* Constraint declarations

  A constraint declaration looks like this:

        constraint {
          equations...
          equations...
          equations...
        }

  Equations are arithmetic expressions with equals signs, such as

        T1.start.x = 12;

  or

        start + end = 2 * center;

  The important thing to know is that equations *must* be linear.  No
  multiplication or division may involve more than one feature.  


        * type definitions
        * constraint and drawable declarations
        * "require" declarations
        * perl code

Type definitions are just more collections of 

----------------------------------------------------------------


        define TYPE {
          subpart name, name, name...;
          subpart name(v=EXPR, ...);
          constraints { 
            EXPR = EXPR = EXPR ... ;
          }
          draw { &perl_function;
                 subpart; subpart;
               }
        }

        require "file";

