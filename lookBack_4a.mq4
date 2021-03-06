//+------------------------------------------------------------------+
//|                                                   lookBack_4.mq4 |
//| rysuje linie dziennego Hi/Lo dla ka�dej timeframe                |
//| badany zakres jest funkcj� pochodnej zmienno�ci                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, 2014 chew-z"
#property link      "LookBack 4 - ro�nie zmienno��, skracaj okres"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green    // Color of the High line
#property indicator_color2 Red      // Color of the Low line
#property indicator_color3 Gold     // Color of the MA line
//---- buffers
double HighBuffer[];
double LowBuffer[];
double MABuffer[];
//---- indicator parameters

//---- alerts
extern int     AlertCandle         = 0;      // 1 - last fully formed candle, 0 - current forming candle

datetime       LastAlertTime       = -999999;
string         AlertTextCrossUp    = "lookback cross UP";
string         AlertTextCrossDown  = "lookback cross DOWN";

//--- parameters
double TodayVol, YestVol, deltaVol;

int iDay;
double MA;

int init()  {
   AlertEmailSubject = Symbol() + " lookback alert";
   LastAlertTime = Time[0]; //experimental - supresses series of crazy alerts sent after terminal start
   SetIndexBuffer(2,MABuffer);
   SetIndexBuffer(1,LowBuffer); 
   SetIndexBuffer(0,HighBuffer);
   SetIndexStyle (2,DRAW_LINE,STYLE_SOLID, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID, 2);
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID, 2);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }
int deinit()    {
   return(0);
   }
int start()    { 
     int i,                       // indeksy
         Counted_bars;            // Number of counted bars
     Counted_bars = IndicatorCounted();  // Number of counted bars
     i = Bars-Counted_bars-1;            // Index of the first uncounted
    while(i>=0)    {                  // Loop for uncounted bars
       
       iDay = iBarShift(NULL, PERIOD_D1, Time[i],false) + 1; //Zamienia indeks bie��cego baru na indeks dziennego Open (!! z poprzedniego dnia !!)
    // Pierwszy wskaznik to aktualne StdDev
       TodayVol = iStdDev(NULL,PERIOD_D1,EMA,iDay,MODE_EMA,PRICE_CLOSE,0);
    // Drugi wska�nik to StdDev cofni�te o Shift dni (!!) niezale�nie od timeframe wykresu   
       YestVol = iStdDev(NULL,PERIOD_D1,EMA,Shift+iDay,MODE_EMA,PRICE_CLOSE,0);  
    // Trzeci wskaznik to liczba lookbackDays
          if(YestVol!=0)
          deltaVol = MathLog(TodayVol  / YestVol) ;        // 
          lookBackDays = maxPeriod / 2;
          if(deltaVol > 0.028)
             lookBackDays = maxPeriod;
          if(deltaVol < -0.028)
             lookBackDays = minPeriod;   

    // Teraz sprawdzamy Highest High i Lowest Low dla dziennych w zakresie lookBackDays
       H = iHigh(NULL, PERIOD_D1, iHighest(NULL,PERIOD_D1,MODE_HIGH,lookBackDays,iDay)); // value(shift(symbol, okres, etc.. ) - kurwa magic ale chyba dzia�a
       L = iLow(NULL, PERIOD_D1, iLowest(NULL,PERIOD_D1,MODE_LOW,lookBackDays,iDay));
       MA = iMA(NULL, PERIOD_D1, EMA, iDay, MODE_EMA, PRICE_MEDIAN, 0);                  // iDay przelicza tutaj offset
       HighBuffer[i] = H;
       LowBuffer[i] = L;
       MABuffer[i] = MA;
       i--; 
    } // while
    ProcessAlerts();
   return(0); // exit
}

int ProcessAlerts()   {                                                                                                                         //
string AlertText = "";
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   { // Time[0] = Open time. So one alert per new bar
    // Upper band
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line) 
    if (Close[AlertCandle] > HighBuffer[AlertCandle]  &&  Close[AlertCandle+1] <= HighBuffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < HighBuffer[AlertCandle]  && Close[AlertCandle+1] >= HighBuffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": H :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // Lower band
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
    if (Close[AlertCandle] > LowBuffer[AlertCandle]  &&  Close[AlertCandle+1] <= LowBuffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < LowBuffer[AlertCandle]  && Close[AlertCandle+1] >= LowBuffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": L :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];                                                                                
    }
    // Moving average
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
    if (Close[AlertCandle] > MABuffer[AlertCandle]  &&  Close[AlertCandle+1] <= MABuffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": MA :" + AlertTextCrossUp;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < MABuffer[AlertCandle]  && Close[AlertCandle+1] >= MABuffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": MA :" + AlertTextCrossDown; 
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];                                                                                
    }                                                                                                         
  }                                                                                                           
  return(0);                                                                                                  
}                                                                                                             

