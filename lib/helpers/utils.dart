logger() { 
  Utils.setVerboseState(); 
  Utils.getLogger();  
}
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
_loggerBuilder(name) {
  if(name == "Verbose"){
    File file = new File("log.txt");
    if (file.existsSync()){
      file.deleteSync();  
    }      
    return new LoggerImpl(name, debugEnabled: true, errorEnabled:true, infoEnabled:true, warnEnabled:true,appenders:[new FileAppender("log.txt")]); 
  }         
  // default logger for the rest
  return new LoggerImpl(name, debugEnabled: false, errorEnabled:true, infoEnabled:false, warnEnabled:true);
}
class Utils{
  static Logger logger;
  static Logger getLogger(){
    if (logger === null){
      LoggerFactory.builder = _loggerBuilder;      
      logger = LoggerFactory.getLogger("Runtime");
    } 
    return logger;
  }
  static setVerboseState(){
    LoggerFactory.builder = _loggerBuilder;    
    logger = LoggerFactory.getLogger("Verbose");    
  }
}