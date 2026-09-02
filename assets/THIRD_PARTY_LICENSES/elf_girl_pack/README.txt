ELF GIRL BEDROOM PACK  -  v1.0
Top-down interior furniture, props, architecture and tiles
by AwakenPrism  -  https://awakenprism.itch.io


WHAT'S IN HERE

  Furniture/        26 objects, front and back views      52 PNGs
  Clutter/          24 small props for surfaces & floors  24 PNGs
  WallDecor/        12 pieces that hang flat on a wall    12 PNGs
  Architecture/     doors, windows, stairs, lighting      16 PNGs
  Tiles/Floors/     5 floors + 3 outdoor ground            9 PNGs
  Tiles/Walls/      wall kit + 4 wall textures            19 PNGs
  Tiles/DualGrid/   autotiling set                         6 PNGs
  Sheets/           one horizontal sprite sheet per category
  Previews/         room renders and showcase sheets

  Please read LICENSE.txt before using these in a project.


SCALE  -  read this first

  160 pixels = 1 metre. Everything is built to that one number, so a mug, a
  wardrobe and a doorway are all correctly sized against each other and against
  a character about 300 px tall.

  Tiles are 160 x 160. Props are sized in whole tiles: 160x160, 160x320,
  320x320, 320x480, 480x480 and so on.


PLACING PROPS  -  the one rule that matters

  Every sprite is GROUNDED to the bottom of its cell, so a tall object occupies
  the tiles ABOVE its anchor, not below it:

      tiles_tall = sprite_height / 160
      occupies rows (anchor_row - tiles_tall + 1) ... anchor_row

  A 480 px wardrobe is 3 tiles tall: anchored on row 4 it fills rows 2, 3, 4.
  Anchor it on row 2 and it overlaps whatever is on row 0 - usually a wall.

  Affects: wardrobe, bookshelf, room divider, clock, door, archway, pillar.


TWO KINDS OF VIEW

  Most props are drawn in a top-down OBLIQUE three-quarter view: you see the top
  surface and the front face.

  WallDecor/ and some Architecture pieces (door, window, archway) are drawn
  STRAIGHT ON, flat, because they sit against a wall. Do not mix them up - a
  picture at a three-quarter angle cannot sit flat on a wall tile.


THE WALL KIT

  wall_straight        horizontal wall: wooden top cap + plaster face
  wall_straight_wood   the same with wood panelling
  wall_window          a straight wall with a window set into it
  wall_corner_tl/tr/bl/br    corners - the cap turns to meet the side wall
  wall_end / wall_end_right  a wall that stops
  wall_doorway_left / right  door jambs
  wall_vertical        a wall running toward the viewer (left and right sides)
  wall_bottom          the bottom edge of a room
  skirting             floor-to-wall trim
  wall_shadow          drop shadow decal, place on the floor under a wall

  DOORWAYS: place wall_doorway_left and wall_doorway_right ONE TILE APART and
  leave the tile between them empty. That gap is the opening and gives a 0.9 m
  door. Butting the jambs together leaves a 32 px slot that vanishes at room
  scale.

  BOTTOM WALLS look different on purpose. At the bottom edge of a room the
  wall's face points away from the camera, so you only see its top surface - a
  thin band. Do not flip wall_straight for this; use wall_bottom.

  SIDE WALLS are full tiles, the same thickness as the top wall. A thinner band
  cannot meet a thick horizontal wall without stepping at the join.


THE DUAL-GRID TILES

  Tiles/DualGrid/ is an autotiling set for the dual-grid method: the display
  layer is offset from the world layer by half a tile, and each display tile is
  chosen from its four overlapping neighbours. 16 cases, which collapse to these
  shapes once your engine rotates them:

      dual_full        all four corners inside
      dual_outer       one corner inside
      dual_edge        two adjacent corners inside
      dual_inner       three corners inside
      dual_diagonal    two opposite corners inside

  Interiors are cut from dual_material, so the shapes can be laid over any
  seamless floor tile and the fill shows through.

  Corner arcs cross every tile boundary at exactly 80 px, so pieces always meet.


USING THEM

  Set import filtering to POINT / NEAREST NEIGHBOUR, not bilinear.

  Scale by whole numbers only (2x, 3x, 4x). Fractional scaling breaks the grid.

  Floor and wall texture tiles are seamless and opaque, filling their cell edge
  to edge. Props and wall-kit pieces are transparent PNGs.


SPRITE SHEETS

  Sheets/ holds one HORIZONTAL strip per category - a single row, uniform cells,
  each sprite grounded and centred in its cell:

      furniture_front.png   26 frames, 480 x 480 cells
      furniture_back.png    26 frames, 480 x 480 cells
      architecture.png      16 frames, 320 x 480 cells
      clutter.png           24 frames, 160 x 320 cells
      wall_decor.png        12 frames, 160 x 320 cells
      tiles_floors.png       9 frames, 160 x 160 cells
      tiles_walls.png       19 frames, 160 x 160 cells
      tiles_dualgrid.png     6 frames, 160 x 160 cells

  The individual PNGs in each folder are the same art at its own native size if
  you would rather not slice a sheet.


SUPPORT

  Something not working, or want to do something the licence doesn't cover?
  Message me through my itch.io page.

  https://awakenprism.itch.io
