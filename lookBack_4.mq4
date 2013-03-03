//+------------------------------------------------------------------+
//|                                                   lookBack_4.mq4 |
//| rysuje linie dziennego Hi/Lo dla ka¿dej timeframe                |
//| badany zakres jest funkcj¹ pochodnej zmiennoœci                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, chew-z"
#property link      "LookBack 4 - roœnie zmiennoœæ, skracaj okres"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green    // Color of the High line
#property indicator_color2 Red      // Color of the Low line
#property indicator_color3 Gold     // Color of the MA line
//---- indicator parameters
extern int       EMA = 60;
extern int     Shift = 1;
extern int minPeriod = 5;
extern int maxPeriod = 20;
//---- buffers
double HighBuffer[];
double LowBuffer[];
double MABuffer[];
//--- parameters
double TodayVol, YestVol, deltaVol;
int lookBackDays = 10;
int iDay;
double H, L, MA;

int init()
  {
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

int start()    { 
   int i,                       // indeksy
       Counted_bars;            // Number of counted bars
   
   Counted_bars = IndicatorCounted();  // Number of counted bars
   i = Bars-Counted_bars-1;            // Index of the first uncounted
while(i>=0)    {                  // Loop for uncounted bars
   
   iDay = iBarShift(NULL, PERIOD_D1, Time[i],false) + 1; //Zamienia indeks bie¿¹cego baru na indeks dziennego Open (!! z poprzedniego dnia !!)
// Pierwszy wskaznik to aktualne StdDev
   TodayVol = iStdDev(NULL,PERIOD_D1,EMA,iDay,MODE_EMA,PRICE_CLOSE,0);
// Drugi wskaŸnik to StdDev cofniête o Shift dni (!!) niezale¿nie od timeframe wykresu   
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
   H = iHigh(NULL, PERIOD_D1, iHighest(NULL,PERIOD_D1,MODE_HIGH,lookBackDays,iDay)); // value(shift(symbol, okres, etc.. ) - kurwa magic ale chyba dzia³a
   L = iLow(NULL, PERIOD_D1, iLowest(NULL,PERIOD_D1,MODE_LOW,lookBackDays,iDay));
   MA = iMA(NULL, PERIOD_D1, EMA, iDay, MODE_EMA, PRICE_MEDIAN, 0);                  // iDay przelicza tutaj offset
   HighBuffer[i] = H;
   LowBuffer[i] = L;
   MABuffer[i] = MA;
   i--; 
} // while
   return(0); // exit
}

int deinit()     {
   Comment("");
}