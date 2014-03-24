//+------------------------------------------------------------------+
//|                                                   levels.mq4              |
//| rysuje dwa zadane poziomy wsparcia i dwa oporu  |
//| dodatkowo wysyła alerty                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "levels_4a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red      // Color of the High line 2
#property indicator_color2 Red      // Color of the High line 1
#property indicator_color3 Green    // Color of the Low line 1
#property indicator_color4 Green    // Color of the Low line 2
//---- indicator parameters
extern double H2 = 1.31;
extern double H1 = 1.30;
extern double L1 = 1.29;
extern double L2 = 1.28;
//---- buffers
double High2Buffer[];
double High1Buffer[];
double Low1Buffer[];
double Low2Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " cross UP";
string         AlertTextCrossDown  = " cross DOWN";

int init()  {
   AlertEmailSubject = Symbol() + " levels alert";
   GlobalVariableSet(StringConcatenate(Symbol(), "levels"), 0);
   SetIndexBuffer(3,High2Buffer);
   SetIndexBuffer(2,High1Buffer);
   SetIndexBuffer(1,Low1Buffer); 
   SetIndexBuffer(0,Low2Buffer);
   SetIndexStyle (3,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexStyle (2,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexDrawBegin(3,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }
int deinit()    {
   GlobalVariableDel(StringConcatenate(Symbol(), "levels"));
   return(0);
   }
int start()    { 
  counter = GlobalVariableGet(StringConcatenate(Symbol(), "_levels"));
  if ( counter < 1 ) {
      int i,                       // indeksy
      Counted_bars;       // Number of counted bars
      Counted_bars = IndicatorCounted();  // Number of counted bars
      i = Bars-Counted_bars-1;            // Index of the first uncounted
      while(i>=0)    {                  // Loop for uncounted bars
         High2Buffer[i] = H2;
         High1Buffer[i] = H1;
         Low1Buffer[i] = L1;
         Low2Buffer[i] = L2;
         i--; 
      } // while
      ProcessAlerts();
      counter = MaxCounter;
      GlobalVariableSet(StringConcatenate(Symbol(), "_levels"), counter);
  } else { // iddle for N ticks
      counter--;
      GlobalVariableSet(StringConcatenate(Symbol(), "_levels"), counter);
  }
    
   return(0); // exit
}

int ProcessAlerts()   {                                                                                                                         //
string AlertText = "";
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   { // Time[0] = Open time. So one alert per new bar
    // Upper bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line) 
    if (Close[AlertCandle] > High2Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= High2Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H2 :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H2 = " + DoubleToStr(H2, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
   if (Close[AlertCandle] < High2Buffer[AlertCandle]  && Close[AlertCandle+1] >= High2Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H2 :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H2 = " + DoubleToStr(H2, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
   if (Close[AlertCandle] > High1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= High1Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H1 :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H1 = " + DoubleToStr(H1, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < High1Buffer[AlertCandle]  && Close[AlertCandle+1] >= High1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H1 :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H1 = " + DoubleToStr(H1, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // Lower bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
    if (Close[AlertCandle] > Low1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= Low1Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L1 :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L1 = " + DoubleToStr(L1, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < Low1Buffer[AlertCandle]  && Close[AlertCandle+1] >= Low1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L1 :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L1 = " + DoubleToStr(L1, 5) ; 
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];                                                                                
    }
   // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
   if (Close[AlertCandle] > Low2Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= Low2Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L2 :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L2 = " + DoubleToStr(L2, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < Low2Buffer[AlertCandle]  && Close[AlertCandle+1] >= Low2Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L2 :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L2 = " + DoubleToStr(L2, 5) ; 
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];                                                                                
    }
                                                                                                     
  }                                                                                                           
  return(0);                                                                                                  
}                          