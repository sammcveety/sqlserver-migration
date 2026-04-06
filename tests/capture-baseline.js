/**
 * Baseline Capture Script for Pharmacy ASP.NET Web Forms App
 *
 * This app uses ASP.NET postback buttons — data loads when you click
 * buttons, which POST to the same page with __VIEWSTATE. Playwright
 * handles this naturally by clicking buttons and waiting for navigation.
 */

const { chromium } = require("playwright");
const fs = require("fs");
const path = require("path");

const BASE_URL = process.env.BASE_URL || "http://localhost:8080";
const BASELINE_DIR = path.join(__dirname, "..", "baselines");

// ---------------------------------------------------------------------------
// Page captures: static pages + postback-triggered data pages
// ---------------------------------------------------------------------------

const STATIC_PAGES = [
  { url: "/Frontpage.aspx", label: "frontpage" },
  { url: "/Login.aspx", label: "login" },
  { url: "/Signup.aspx", label: "signup" },
  { url: "/Home.aspx", label: "home" },
  { url: "/Medicine.aspx", label: "medicine" },
  { url: "/Employ.aspx", label: "employ" },
  { url: "/Dealer.aspx", label: "dealer" },
  { url: "/Purchase.aspx", label: "purchase" },
  { url: "/About.aspx", label: "about" },
];

// These pages are reached by clicking a button on a source page,
// which sets a session variable and redirects to an output page.
const POSTBACK_FLOWS = [
  // Medicine page flows
  {
    label: "medicine-show-all",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button1",
    description: "Show All Medicines (Show_All_Medicine proc)",
  },
  {
    label: "medicine-out-of-stock",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button2",
    description: "Show Out of Stock (Show_outofstock proc)",
  },
  {
    label: "medicine-all-expired",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button3",
    description: "Show All Expired (Show_All_Expired proc)",
  },
  {
    label: "medicine-find-price",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button4",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox1": "12M" },
    description: "Find Price by ID (Find_Price proc)",
  },
  {
    label: "medicine-find-expiry",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button5",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox2": "12M" },
    description: "Find Expiry by ID (Find_Expiry proc)",
  },
  {
    label: "medicine-who-took",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button6",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox3": "12M" },
    description: "Who took this medicine (Who_took_these proc)",
  },
  {
    label: "medicine-all-info",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button7",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox4": "12M" },
    description: "Find All Info (Find_All_Info proc)",
  },
  {
    label: "medicine-quantity-left",
    sourcePage: "/Medicine.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button8",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox5": "12M" },
    description: "Quantity Left (Quantityleft proc)",
  },
  // Employee page flows
  {
    label: "employ-show-all",
    sourcePage: "/Employ.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button1",
    description: "Show All Employees",
  },
  {
    label: "employ-find-by-id",
    sourcePage: "/Employ.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button2",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox1": "3" },
    description: "Find Employee by ID (Find_Employ proc)",
  },
  {
    label: "employ-find-by-name",
    sourcePage: "/Employ.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button3",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox2": "Saqib" },
    description: "Find Employee by Name (Find_Employ_Name proc)",
  },
  // Dealer page flows
  {
    label: "dealer-show-all",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button1",
    description: "Show All Dealers",
  },
  {
    label: "dealer-show-companies",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button2",
    description: "Show All Companies",
  },
  {
    label: "dealer-show-purchases",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button3",
    description: "Show All Purchases",
  },
  {
    label: "dealer-show-sales",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button4",
    description: "Show All Sales",
  },
  {
    label: "dealer-find-by-id",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button5",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox1": "11D" },
    description: "Find Dealer by ID (Find_Dealer proc)",
  },
  {
    label: "dealer-by-company",
    sourcePage: "/Dealer.aspx",
    buttonId: "ctl00_ContentPlaceHolder1_Button6",
    fillFirst: { "ctl00_ContentPlaceHolder1_Textbox2": "10C" },
    description: "Dealer by Company ID (DealernamefromCompID proc)",
  },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

async function extractPageData(page) {
  return page.evaluate(() => {
    const data = {};

    const tables = document.querySelectorAll("table");
    data.tables = Array.from(tables).map((table, idx) => {
      const headers = Array.from(table.querySelectorAll("tr:first-child th")).map(
        (th) => th.textContent.trim()
      );
      const rows = Array.from(table.querySelectorAll("tr")).slice(headers.length > 0 ? 1 : 0).map((tr) =>
        Array.from(tr.querySelectorAll("td")).map((td) => td.textContent.trim())
      ).filter(r => r.length > 0);
      return { index: idx, headers, rows };
    });

    data.headings = Array.from(
      document.querySelectorAll("h1, h2, h3, h4, h5, h6")
    ).map((h) => ({ tag: h.tagName, text: h.textContent.trim() }));

    const forms = document.querySelectorAll("form");
    data.forms = Array.from(forms).map((form) => ({
      action: form.action,
      method: form.method,
      fields: Array.from(
        form.querySelectorAll("input:not([type=hidden]), select, textarea")
      ).map((el) => ({
        type: el.type || el.tagName.toLowerCase(),
        name: el.name,
        id: el.id,
        value: el.type === "password" ? "" : el.value,
      })),
    }));

    data.gridviews = Array.from(
      document.querySelectorAll("[id*=GridView]")
    ).map((gv) => {
      const headers = Array.from(gv.querySelectorAll("tr:first-child th")).map(
        (th) => th.textContent.trim()
      );
      const rows = Array.from(gv.querySelectorAll("tr"))
        .slice(1)
        .map((tr) =>
          Array.from(tr.querySelectorAll("td")).map((td) => td.textContent.trim())
        );
      return { id: gv.id, headers, rows };
    });

    data.labels = Array.from(
      document.querySelectorAll("span[id*=Label]")
    ).map((l) => ({ id: l.id, text: l.textContent.trim() }));

    return data;
  });
}

async function capturePage(page, label, outputDir) {
  const dir = path.join(outputDir, label);
  fs.mkdirSync(dir, { recursive: true });

  await page.waitForTimeout(500);

  await page.screenshot({
    path: path.join(dir, "screenshot.png"),
    fullPage: true,
  });

  const html = await page.content();
  fs.writeFileSync(path.join(dir, "snapshot.html"), html);

  const data = await extractPageData(page);
  data.url = page.url();
  data.timestamp = new Date().toISOString();
  fs.writeFileSync(path.join(dir, "data.json"), JSON.stringify(data, null, 2));

  const gridviewCount = data.gridviews.length;
  const rowCount = data.gridviews.reduce((sum, gv) => sum + gv.rows.length, 0);
  console.log(`  [${label}] ${data.url} (${gridviewCount} gridviews, ${rowCount} data rows)`);

  return { label, gridviews: gridviewCount, rows: rowCount, data };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const outputDir = process.argv[2] || BASELINE_DIR;
  console.log(`Capturing baselines to: ${outputDir}`);
  fs.mkdirSync(outputDir, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const summary = [];

  try {
    const ctx = await browser.newContext();
    const page = await ctx.newPage();

    // ---- Static pages ----
    console.log("\n--- Static pages ---");
    for (const sp of STATIC_PAGES) {
      await page.goto(`${BASE_URL}${sp.url}`, { waitUntil: "networkidle", timeout: 15000 });
      const result = await capturePage(page, sp.label, outputDir);
      summary.push({ label: result.label, gridviews: result.gridviews, rows: result.rows });
    }

    // ---- Postback flows (click button -> capture result page) ----
    console.log("\n--- Postback data flows ---");
    for (const flow of POSTBACK_FLOWS) {
      console.log(`  [flow] ${flow.label}: ${flow.description}`);

      // Navigate to the source page
      await page.goto(`${BASE_URL}${flow.sourcePage}`, { waitUntil: "networkidle", timeout: 15000 });

      // Fill any required text fields first
      if (flow.fillFirst) {
        for (const [id, value] of Object.entries(flow.fillFirst)) {
          await page.fill(`#${id}`, value).catch((e) => {
            console.log(`    warning: couldn't fill #${id}: ${e.message}`);
          });
        }
      }

      // Click the button and wait for navigation (ASP.NET postback redirects)
      try {
        await Promise.all([
          page.waitForNavigation({ waitUntil: "networkidle", timeout: 15000 }).catch(() => {}),
          page.click(`#${flow.buttonId}`),
        ]);
      } catch (e) {
        console.log(`    click error: ${e.message}`);
      }

      // Capture the result page
      const result = await capturePage(page, flow.label, outputDir);
      summary.push({ label: result.label, gridviews: result.gridviews, rows: result.rows });
    }

    await ctx.close();
  } finally {
    await browser.close();
  }

  // Write summary
  fs.writeFileSync(
    path.join(outputDir, "summary.json"),
    JSON.stringify({ captured: new Date().toISOString(), routes: summary }, null, 2)
  );

  const totalPages = summary.length;
  const totalRows = summary.reduce((sum, s) => sum + s.rows, 0);
  console.log(`\n--- Summary ---`);
  console.log(`Captured ${totalPages} pages, ${totalRows} total data rows`);
}

main().catch((err) => {
  console.error("Capture failed:", err);
  process.exit(1);
});
