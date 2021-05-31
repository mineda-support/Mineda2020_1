# PMOS process description demonstrating:
# - Source/Drain diffusion
# - Al Gate formation
# - Contact to Source/Drain and Al gate
# - 2nd metal layer formation

#No Well
#No Field oxide
#Gate and 1st metal formation
#2nd metal formation

# Pick a 10x finer database unit for enhanced accuracy:
dbu(dbu * 0.1)

# Basic options: declare the depth of the simulation and the height.
# These are the defaults:
#   depth(10.0)
#   height(10.0)
# Declare the basic accuracy used to remove artefacts for example:
delta(5 * dbu)
height(50.0)
# Declaration the layout layers.
# Possible operations are (l1 = layer(..); l2 = layer(..))
#   "or"     l1.or(l2)
#   "and"    l1.and(l2)
#   "xor"    l1.xor(l2)
#   "not"    l1.not(l2)
#   "size"   l1.sized(s)     (s in micron units)
#     or     l1.sized(x, y)  (x, y in micron units)
#   "invert" l1.inverted
#Layers Definition

diff   = layer("3/0")
cnt    = layer("7/0") 
ml1    = layer("8/0").inverted
via1   = layer("9/0")
ml2    = layer("10/0").inverted
#mgate = ml11.inverted
#mline = ml12.inverted
parea  = layer("18/0")
pdiff  = diff 

#### layer Thichness
  yfactor = 10.0
  tsub   = 4.00
  tox    = 0.06 * yfactor
  tcnt   = 0.06 * yfactor
  tml1a  = 0.3  * yfactor
  tvia1  = 0.3  * yfactor
  tteos1 = 0.3  * yfactor
  tml2a  = 0.55  * yfactor
  
# Process steps:
# Now we move to cross section view: from the layout geometry we create 
# a material stack by simulating the process step by step. 
# The basic idea is that all activity happens at the surface. We can
# deposit material (over existing or at a mask), etch material and
# planarize. 
# A material is a 2D geometry as seen in the cross section along the
# measurement line.
# The following steps mimic a simple process.

# Start with the n doped bulk and assign that to material "nbulk"
# "bulk" delivers the wafer's cross section. 

nbulk = bulk
# Create SUB
 # sub = deposit(tsub ,0.3)
  
# B dope

  pplus = mask(pdiff).grow(1.0, 1.7, :mode => :round, :into => nbulk)

# deposit 60nm gate oxide.
# "deposit" is an alias for "all.grow" where "all" is a special mask covering "everything".
  gox = deposit(tox)

# etch the gate and source/drain contacts
# "taper" will make the holes conical with a sidewall angle of 5 degree.

  mask(cnt).etch(tcnt, :into => gox, :taper => 4)

  
  ## Metal1 deposit alu1:metal1 deposit
  
  alu1 = deposit(tml1a, :mode => :round)
#  alu1 = deposit(3.0)

  ### metal1 etching( mask: ml1)##
  
  mask(ml1).etch(tml1a, :into => alu1, :taper => 8)

  # deposit isolation TEOS layer
  
  iso1 = deposit(tteos1,tteos1/2.0, :mode => :round)

# tungsten CMP: take off 0.45 micron measured from the top level of the
# w, iso materials from w and iso. 
# Alternative specifications are: 
#   :downto => {material(s)}   planarize down to these materials
#   :to => z                   planarize to the given z position measured from 0 (the initial wafer surface) 
#planarize(:into => [w, iso], :less => 0.65)

# ml1 isolation and etch, metal deposition and CMP 
#iso2 = deposit(0.3*vscale)

  ### Etching iso1 for M1-M2 contact##
  mask(via1).etch(tvia1, :into => iso1,:taper =>5)

  ### Deposit metal2 all region ##
  alu2 = deposit(tml2a,0.1,:mode => :round)

  ## Etching Metal2 Layer By ml2
  mask(ml2).etch(tml2a,0.5, :into => alu2, :taper => 5)
  
#planarize(:into => [alu1], :less => 0.3)


# finally output all result material.
# output specification can be scattered throughout the script but it is 
# easier to read when put at the end.
#output("sub (299/0)", sub)
  output("pplus (300/0)", pplus)

  output("gox (301/0)", gox)
output("alu1 (311/0)", alu1)

output("iso1 (310/0)", iso1)

output("alu2 (400/0)", alu2)

layers_file("YSS-PMOS_Xsection.lyp")


