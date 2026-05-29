// ============================================================
// DataExport.cs
// Component:   Shared Export Utility — Presentation Layer
// Module:      CTEC2713N — DriveNow Agile Team Project
//
// Purpose:
//   Provides a single reusable method to export any DataTable
//   to CSV format and stream it directly to the browser as a
//   downloadable file that opens in Microsoft Excel.
//
// Usage (from any code-behind):
//   DataTable dt = ... fetch data ...
//   DataExport.DownloadCsv(Response, dt, "vehicles");
//
// CSV format notes:
//   - Header row uses column names from the DataTable
//   - Cell values containing commas or double-quotes are wrapped
//     in double-quotes and internal quotes are escaped as ""
//   - UTF-8 BOM is prepended so Excel reads accented characters
//     correctly without needing manual encoding selection
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
        /// Values that contain commas, double-quotes or newlines are wrapped
        /// in double-quotes; embedded double-quotes are doubled ("").
        /// </summary>
        public static string ToCsv(DataTable dt)
        {
            if (dt == null) return string.Empty;

            var sb = new StringBuilder();

            // ── Header row ─────────────────────────────────────────────────
            for (int c = 0; c < dt.Columns.Count; c++)
            {
                if (c > 0) sb.Append(',');
                sb.Append(EscapeCell(dt.Columns[c].ColumnName));
            }
            sb.AppendLine();

            // ── Data rows ──────────────────────────────────────────────────
            foreach (DataRow row in dt.Rows)
            {
                for (int c = 0; c < dt.Columns.Count; c++)
                {
                    if (c > 0) sb.Append(',');
                    string val = row[c] == DBNull.Value ? "" : row[c].ToString();

                    // Format DateTime values into a readable Excel-friendly form
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
        /// Streams a DataTable to the browser as a downloadable CSV file.
        /// Call this as the last action in a button handler — nothing should
        /// run after Response.End().
        /// </summary>
        /// <param name="response">HttpResponse from the current page.</param>
        /// <param name="dt">DataTable containing the data to export.</param>
        /// <param name="fileBaseName">
        ///   Base filename without extension, e.g. "vehicles".
        ///   The current date is appended automatically:
        ///   vehicles_2026-05-20.csv
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

            // ContentDisposition triggers the Save-As / Download dialog
            response.AddHeader("Content-Disposition",
                string.Format("attachment; filename=\"{0}\"", filename));

            // UTF-8 BOM — makes Excel auto-detect encoding correctly
            response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });
            response.Write(csv);
            response.Flush();
            response.End();
        }

        // ── Private helpers ───────────────────────────────────────────────

        /// <summary>
        /// Wraps a cell value in double-quotes if it contains a comma,
        /// double-quote, newline, or leading/trailing whitespace.
        /// Embedded double-quotes are escaped as "".
        /// </summary>
        private static string EscapeCell(string value)
        {
            if (value == null) return "\"\"";
            bool needsQuoting = value.IndexOf(',')  >= 0
                             || value.IndexOf('"')  >= 0
                             || value.IndexOf('\n') >= 0
                             || value.IndexOf('\r') >= 0
                             || value != value.Trim();

            if (!needsQuoting) return value;
            return "\"" + value.Replace("\"", "\"\"") + "\"";
        }
    }
}
