ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))
LIB_PATH = File.join(ROOT_PATH, "lib")
$LOAD_PATH.unshift(*Dir.glob(File.join(LIB_PATH, "**", "*")))