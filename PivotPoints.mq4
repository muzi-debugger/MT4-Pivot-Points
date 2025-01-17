#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue    // Pivot Point
#property indicator_color2 Red     // Support 1
#property indicator_color3 Red     // Support 2
#property indicator_color4 Red     // Support 3
#property indicator_color5 Green   // Resistance 1
#property indicator_color6 Green   // Resistance 2
#property indicator_color7 Green   // Resistance 3

double PPBuffer[];  // Pivot Point
double S1Buffer[];  // Support 1
double S2Buffer[];  // Support 2
double S3Buffer[];  // Support 3
double R1Buffer[];  // Resistance 1
double R2Buffer[];  // Resistance 2
double R3Buffer[];  // Resistance 3

input bool ShowOnlyRelevantTimeframes = true; // Only show on relevant timeframes (Weekly, Daily, 4H, 1H)

// Initialize buffers
int OnInit() {
   SetIndexStyle(0, DRAW_LINE); SetIndexBuffer(0, PPBuffer); SetIndexLabel(0, "Pivot Point");
   SetIndexStyle(1, DRAW_LINE); SetIndexBuffer(1, S1Buffer); SetIndexLabel(1, "S1");
   SetIndexStyle(2, DRAW_LINE); SetIndexBuffer(2, S2Buffer); SetIndexLabel(2, "S2");
   SetIndexStyle(3, DRAW_LINE); SetIndexBuffer(3, S3Buffer); SetIndexLabel(3, "S3");
   SetIndexStyle(4, DRAW_LINE); SetIndexBuffer(4, R1Buffer); SetIndexLabel(4, "R1");
   SetIndexStyle(5, DRAW_LINE); SetIndexBuffer(5, R2Buffer); SetIndexLabel(5, "R2");
   SetIndexStyle(6, DRAW_LINE); SetIndexBuffer(6, R3Buffer); SetIndexLabel(6, "R3");

   IndicatorShortName("Pivot Points");
   return(INIT_SUCCEEDED);
}

// Function to determine the source timeframe
bool IsRelevantTimeframe() {
   switch (Period()) {
      case PERIOD_H1:
      case PERIOD_H4:
      case PERIOD_D1:
      case PERIOD_W1:
         return true;
      default:
         return false;
   }
}

// Draw horizontal lines for pivot points
void DrawHorizontalLine(double value, string name, color lineColor) {
   if (ObjectFind(0, name) != 0) {
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, value);
      ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, value);
}

// Calculate pivot points
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[]) {

   // Check if the current timeframe is relevant
   if (ShowOnlyRelevantTimeframes && !IsRelevantTimeframe()) {
      // Remove existing objects if not on a relevant timeframe
      for (int i = 0; i < 7; i++) {
         string objName = "Pivot_" + IntegerToString(i);
         ObjectDelete(0, objName);
      }
      return(rates_total);
   }

   double highVal = iHigh(NULL, PERIOD_D1, 1);
   double lowVal = iLow(NULL, PERIOD_D1, 1);
   double closeVal = iClose(NULL, PERIOD_D1, 1);

   // Calculate pivot points
   double PP = (highVal + lowVal + closeVal) / 3;
   double S1 = 2 * PP - highVal;
   double S2 = PP - (highVal - lowVal);
   double S3 = lowVal - 2 * (highVal - PP);
   double R1 = 2 * PP - lowVal;
   double R2 = PP + (highVal - lowVal);
   double R3 = highVal + 2 * (PP - lowVal);

   // Draw horizontal lines for pivot points
   DrawHorizontalLine(PP, "Pivot_PP", Blue);
   DrawHorizontalLine(S1, "Pivot_S1", Red);
   DrawHorizontalLine(S2, "Pivot_S2", Red);
   DrawHorizontalLine(S3, "Pivot_S3", Red);
   DrawHorizontalLine(R1, "Pivot_R1", Green);
   DrawHorizontalLine(R2, "Pivot_R2", Green);
   DrawHorizontalLine(R3, "Pivot_R3", Green);

   return(rates_total);
}
