//+------------------------------------------------------------------+
//|                                                   volatility_2a.mq4    |
//| wysyła alerty związne ze zmiennością                     |
//| (ATR, dzienny zakres etc.)                                       |  
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "volatility_2a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window

//---- indicator parameters

//---- buffers

//---- alerts
extern int     AlertCandle        = 0;      // 1 - last fully formed candle, 0 - current forming candle
extern int     lookBackRange  = 5;

int init()    {
   AlertEmailSubject = Symbol() + " volatility alert"; 
   GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), 0);
   return(0);
  }
int deinit()    {
   GlobalVariableDel(StringConcatenate(Symbol(), "_volatility"));
   return(0);
   }
int start()    { 
    if (NewDay()) 
      GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), 0);
    ProcessAlerts();
    return(0); 
}

int ProcessAlerts()   {                                                                                                                         //
string AlertText =  "";
H = iHigh(NULL, PERIOD_D1, iHighest(NULL,PERIOD_D1,MODE_HIGH,lookBackRange,1)); // kurwa magic ale chyba dzia³a
L = iLow (NULL, PERIOD_D1, iLowest (NULL,PERIOD_D1,MODE_LOW,lookBackRange,1));
int semafor = GlobalVariableGet(StringConcatenate(Symbol(), "_volatility"));
   if (semafor < 7)   { //  7 = 1 + 2 + 4 = all flags set

    if(MathMod(semafor, 2) < 1 && (Low[AlertCandle] < iLow(NULL, PERIOD_D1, 1) || High[AlertCandle] > iHigh(NULL, PERIOD_D1, 1)) )  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside yesterday's range. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+1);
    }
    if(MathMod(semafor, 4) < 2 && iHigh(NULL, PERIOD_D1, AlertCandle) - iLow(NULL, PERIOD_D1, AlertCandle) >  iATR(NULL,PERIOD_D1,3,1) )  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside 3-days ATR. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+2);
    }
    if(semafor < 4  && (Low[AlertCandle] < L || High[AlertCandle] > H) )  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside last days range. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+4);
    }
    
   }

    return(0); 
  }                                                                                                      
                                                                                                                        