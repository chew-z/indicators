//+------------------------------------------------------------------+
//|                                        trendline_2b.mq4          |
//| rysuje linie trendu w oparciu o regresję liniową                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014-2015, chew-z"
#property link      "trendline_4a"
#include <TradeTools\TradeTools5.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Orange   // Color of the High trendline
#property indicator_color2 Yellow   // Color of the Low trendline
#property indicator_color3 Blue
//---- indicator parameters
//---- buffers
double Low1Buffer[];
double High1Buffer[];
double N1Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime            = -999999;
datetime       LastRedrawTime           = -999999;
string         AlertTextCrossUp         = " trendline cross UP";
string         AlertTextCrossDown       = " trendline cross DOWN";

int OnInit()    {
    AlertEmailSubject = Symbol() + " trendline alert";
    LastAlertTime = Time[0]; //experimental - supresses series of crazy alerts sent after terminal start

    GlobalVariableSet(StringConcatenate(Symbol(), "_trendline"), 0);

    SetIndexBuffer(2,N1Buffer);
    SetIndexBuffer(1,Low1Buffer);
    SetIndexBuffer(0,High1Buffer);

    SetIndexStyle (2,DRAW_LINE,STYLE_DASH, 1);
    SetIndexStyle (1,DRAW_LINE,STYLE_DASH, 1);
    SetIndexStyle (0,DRAW_LINE,STYLE_DASH, 1);

    SetIndexDrawBegin(2,0);
    SetIndexDrawBegin(1,0);
    SetIndexDrawBegin(0,0);
    if( !IsConnected() )
        Sleep( 5000 );  //wait 5s for establishing connection to trading server
    //Sleep() is automatically passed during testing
    return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){
   GlobalVariableDel(StringConcatenate(Symbol(), "_trendline"));
   Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
   }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])        {

    int i, half, Counted_bars;          // Number of counted bars
    if (Time[0] > LastRedrawTime) { // redraw indicator once in a bartime
        Counted_bars = Bars - rangeX + 1; //tyle bars NIE musimy przelecieć
        LastRedrawTime = Time[0];
        Print("trendline_4a - indicator repaint "+TimeToStr(LastRedrawTime, TIME_MINUTES));
    }  else {
        Counted_bars = IndicatorCounted();  // Number of counted bars
    }
    i = Bars-Counted_bars-1;            // Index of the first uncounted
    double s_Y = 0.0;
    double s_X = 0.0;
    for(j = i, j > 0, j--) {
        s_Y += High[j];
        s_Y += j;
    }
    m_Y = s_Y / j;
    m_X = s_X / j;
    for(j = i, j > 0, j--) {
        s_Y += High[j];
        s_Y += j;
    }



}

double mean_H(int n) {
    double sigma = 0.0;
    for(j = n, j > 0, j--) {
        sigma += High[j];
    }
    return sigma / n;
}

double std(int n, double m) {
    double sigma = 0.0;
    for(j = n, j > 0, j--) {
        sigma += MathPow(High[j] - m)
    }
    return 1.0 / (n-1) * sigma;
}

double pearson(int n, double m_Y) {
    double sum_xy = 0.0;
    double sum_sq_v_x = 0.0;
    double sum_sq_v_y = 0.0;
    double m_X = n * 0.5 * (High[n]+High[1]) //sum of arithmetic progression
    for(j = n, j > 0, j--) {
        double var_x = j - m_X;
        double var_y = High[j] - m_Y;
        sum_xy += var_x * var_y;
        sum_sq_v_x += MathPow(var_x, 2);
        sum_sq_v_y += MathPow(var_y, 2);
    }
    return sum_xy / MathSqrt(sum_sq_v_x * sum_sq_v_y);
}


###############################################################################################
int start()    {
     int i, half, Counted_bars;          // Number of counted bars
     if (Time[0] > LastRedrawTime) { // redraw indicator once in a bartime
          Counted_bars = Bars - rangeX + 1; //tyle bars NIE musimy przelecieć
          LastRedrawTime = Time[0];
          Print("trendline_2b - indicator repaint "+TimeToStr(LastRedrawTime, TIME_MINUTES));
        }  else {
          Counted_bars = IndicatorCounted();  // Number of counted bars
        }
     i = Bars-Counted_bars-1;            // Index of the first uncounted
     half = MathRound((rangeX - blindRange) /2);
     int max1 = iHighest(NULL, 0, MODE_HIGH, rangeX, half+1); //roughly 24 H1 bars per day
     int max2 = iHighest(NULL, 0, MODE_HIGH, half, blindRange);
     if (max1-max2 < blindRange) max2 = iHighest(NULL, 0, MODE_HIGH, half-blindRange, blindRange);
     int min1 = iLowest(NULL, 0, MODE_LOW, rangeX, half+1);
     int min2 = iLowest(NULL, 0, MODE_LOW, half, blindRange);
     if (min1-min2 < blindRange) min2 = iLowest(NULL, 0, MODE_LOW, half-blindRange, blindRange);
     double deltaYh = (High[max1]-High[max2]) / (max1 - max2);    // delta Y High
     double deltaYl = (Low[min2]-Low[min1]) / (min1 - min2);          // delta Y Low
     // Print the dates of peaks and valleys on chart
     Comment("Max1 "+DoubleToStr(High[max1],4)+" "+TimeToStr(Time[max1], TIME_DATE)+" Max2 "+DoubleToStr(High[max2],4)+" "+TimeToStr(Time[max2], TIME_DATE)+
             "\nMin1 "+DoubleToStr(Low[min1],4)+" "+TimeToStr(Time[min1], TIME_DATE)+" Min2 "+DoubleToStr(Low[min2],4)+" "+TimeToStr(Time[min2], TIME_DATE));
     while(i>=0)    {                                      // Loop for uncounted bars
        if(i <= rangeX) {
          High1Buffer[i]  = High[max1] - (max1 - i) * deltaYh;
          Low1Buffer[i]   = Low[min1] + (min1 - i) * deltaYl;
          N1Buffer[i] = (High1Buffer[i] + Low1Buffer[i])/2;
        }
        i--;
      } // while

    ProcessAlerts();
  return(0); // exit
}

int ProcessAlerts()   {
string AlertText = "";
H = High1Buffer[AlertCandle];
L = Low1Buffer[AlertCandle];
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   { // Time[0] = Open time. So one alert per new bar
    // Upper bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
   if (Close[AlertCandle] > High1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= High1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline H :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line)
    if (Close[AlertCandle] < High1Buffer[AlertCandle]  && Close[AlertCandle+1] >= High1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline H :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // Lower bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
    if (Close[AlertCandle] > Low1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= Low1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline L :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line)
    if (Close[AlertCandle] < Low1Buffer[AlertCandle]  && Close[AlertCandle+1] >= Low1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline L :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
  }
  return(0);
}

