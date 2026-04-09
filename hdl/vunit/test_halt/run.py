from vunit import VUnit


def encode(tb_cfg):
    return ", ".join(["%s:%s" % (key, str(tb_cfg[key])) for key in tb_cfg])

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("./*.vhd")
lib.add_source_files("../../library/3rdparty/JohnKent/cpu68_dom.vhd")
lib.add_source_files("../../library/mine/*.vhd")
lib.add_source_files("../../cards/*.vhd")

vu.set_sim_option("disable_ieee_warnings",1)
vu.set_sim_option("modelsim.vsim_flags", ["-voptargs=+acc"])

# Run vunit function
vu.main()
