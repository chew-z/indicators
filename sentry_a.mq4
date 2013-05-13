//+------------------------------------------------------------------+
//|                                                   sentry.mq4     |
//| na kwadrans przed pełną godziną wysyła alert informujący, że OK  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "levels - "

#property indicator_chart_window
#property indicator_buffers 0
//---- alerts

extern bool    quietHours          = true;
extern int     quietStart          = 22;
extern int     quietStop           =  6;
extern int     minute              =  45;
bool           AlertFlag           = false;

int init()
  {

   return(0);
  }

int start()    { 
  string AlertText = "Wszystko OK";
  bool isNewBar;

  if (quietHours == true || AlertFlag == true) {
    if(Hour() >= quietStart || Hour()< quietStop )
      return(0); // exit
    if(Minute() > minute)
      AlertFlag = false;
  }

  if( !IsConnected() ) 
    AlertText = "No connection";

  if (Minute() == minute && AlertFlag == false) {  
      SendNotification(AlertText);
      AlertFlag = true;
  }
  return(0); // exit
}   
 