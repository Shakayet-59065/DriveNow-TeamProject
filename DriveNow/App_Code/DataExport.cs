// ============================================================
// DataExport.cs
// Component:   Shared Export Utility
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// Provides a single reusable method to export any DataTable
// to CSV format and stream it to the browser as a downloadable
// file that opens directly in Microsoft Excel.
//
// Usage (from any code-behind):
//   DataTable dt = ... fetch data ...
//   DataExport.DownloadCsv(Response, dt, "vehicles");
//
// Notes:
//   - UTF-8 BOM is prepended so Excel reads international
//     characters (æ ø å etc.) correctly without manual setup.
//   - Values containing commas, quotes or newlines are wrapped
//     in double-quotes per RFC 4180 (standard CSV spec).
//   - Dates are formatted dd/MM/yyyy HH:mm (Excel-friendly).
//   - The current date is appended to the filename automatically.
// ============================================================

using System;
using System.Data;
using System.Text;
using System.Web;

namespace DriveNow
{
    public static class DataExport
    {
        /// <summary>
        /// Converts a DataTable to a UTF-8 CSV string.
        /// </summary>
        public static string ToCsv(DataTable dt)
        {
            if (dt == null) return string.Empty;

            var sb = new StringBuilder();

            // Header row — use column names from the DataTable
            for (int c = 0; c < dt.Columns.Count; c++)
            {
                if (c > 0) sb.Append(',');
                sb.Append(EscapeCell(dt.Columns[c].ColumnName));
            }
            sb.AppendLine();

            // Data rows
            foreach (DataRow row in dt.Rows)
            {
                for (int c = 0; c < dt.Columns.Count; c++)
                {
                    if (c > 0) sb.Append(',');
                    string val = (row[c] == DBNull.Value) ? "" : row[c].ToString();

                    // Format DateTime values in a readable, Excel-friendly form
                    if (row[c] != DBNull.Value && dt.Columns[c].DataType == typeof(DateTime))
                    {
                        DateTime d;
                        if (DateTime.TryParse(val, out d))
                            val = d.ToString("dd/MM/yyyy HH:mm");
                    }

                    sb.Append(EscapeCell(val));
                }
                sb.AppendLine();
            }

            return sb.ToString();
        }

        /// <summary>
        /// Streams a DataTable to the browser as a downloadable .csv file.
        /// This must be the last call in a button handler — nothing runs after Response.End().
        /// </summary>
        /// <param name="response">The HttpResponse from the current page.</param>
        /// <param name="dt">DataTable to export.</param>
        /// <param name="fileBaseName">
        ///   Filename without extension, e.g. "vehicles".
        ///   Today's date is appended: DriveNow_Vehicles_2026-05-20.csv
        /// </param>
        public static void DownloadCsv(HttpResponse response, DataTable dt, string fileBaseName)
        {
            if (response == null) throw new ArgumentNullException("response");

            string filename = string.Format("{0}_{1:yyyy-MM-dd}.csv",
                fileBaseName.Replace(" ", "_"),
                DateTime.Today);

            string csv = ToCsv(dt);

            response.Clear();
            response.ContentType = "text/csv";
            response.Charset     = "utf-8";
            response.AddHeader("Content-Disposition",
                string.Format("attachment; filename=\"{0}\"", filename));

            // UTF-8 BOM — makes Excel auto-detect encoding (handles æ ø å etc.)
            response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });
            response.Write(csv);
            response.Flush();
            response.End();
        }

        // Wraps a value in double-quotes if it contains commas, quotes or newlines.
        // Embedded double-quotes are doubled ("") per the CSV standard.
        private static string EscapeCell(string value)
        {
            if (value == null) return "\"\"";
            bool needsQuoting = value.IndexOf(',')  >= 0
                             || value.IndexOf('"')  >= 0
                             || value.IndexOf('\n') >= 0
                             || value.IndexOf('\r') >= 0
                             || value != value.Trim();

            return needsQuoting ? "\"" + value.Replace("\"", "\"\"") + "\"" : value;
        }
    }
}
