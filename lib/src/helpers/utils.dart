part of mongo_dart;
setVerboseState(){
  Utils.setVerboseState();  
}
info(String s){
  Utils.getLogger().info(s);
}
warn(String s){
  Utils.getLogger().warn(s);
}
error(String s){
  Utils.getLogger().error(s);
}
debug(String s){
  Utils.getLogger().debug(s);
}
class Utils{
  static Logger logger;
  static Logger getLogger(){
    if (logger === null){
      LoggerFactory.config["Runtime"].infoEnabled = false;
      LoggerFactory.config["Runtime"].debugEnabled = false;      
      logger = LoggerFactory.getLogger("Runtime");
    } 
    return logger;
  }
  static setVerboseState(){
    File file = new File("log.txt");
    if (file.existsSync()){
      file.deleteSync();  
    }
    LoggerFactory.config["Verbose"].appenders =  [new FileAppender("log.txt")];
    LoggerFactory.config["Verbose"].infoEnabled = true;
    LoggerFactory.config["Verbose"].debugEnabled = true;
    logger = LoggerFactory.getLogger("Verbose");    
  }
}