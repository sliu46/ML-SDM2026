# =====================================================
# Merge Web of Science Records
#
# Description:
# This script merges multiple Web of Science Core
# Collection (WoSCC) plain-text export files into a
# single standardized dataset for bibliometric analysis.
#
# The script was developed to combine records exported
# from different time periods (2006–2025) and ensure
# compatibility with VOSviewer, HistCite, and
# Bibliometrix.
#
# Input:
#   data/WoS_raw_records
#
# Output:
#   data/WoS_raw_records/
#   └── V06-25(5224).txt
# =====================================================    
import os
import re
folder_path = r"data/WoS_raw_records"
selected_files = [
    # "06-10(130).txt",
    #"11-15(766.1).txt",
    #"11-15(766.2).txt",
    #"16-20(1442.1).txt",
    #"16-20(1442.2).txt",
    #"16-20(1442.3).txt",
    #"21-25(2886.1).txt",
    #"21-25(2886.2).txt",
    #"21-25(2886.3).txt",
    #"21-25(2886.4).txt",
    #"21-25(2886.5).txt",
    #"21-25(2886.6).txt",
]
output_file = os.path.join(folder_path, "V06-25(5224).txt")
# =========================
# 4. 解析函数（核心）
# =========================
def parse_wos(text):
    # 统一换行
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    # 删除文件头（关键）
    text = re.sub(r"FN .*?\n", "", text)
    text = re.sub(r"VR .*?\n", "", text)
    # 去掉空行污染
    text = re.sub(r"\n{2,}", "\n", text)
    # 按 PT 切分（最稳定方式）
    parts = re.split(r"\nPT\s", text)
    records = []
    for p in parts:
        p = p.strip()
        if not p:
            continue
        # 补回 PT
        if not p.startswith("PT"):
            p = "PT " + p
        # 必须包含 ER（否则跳过）
        if "ER" not in p:
            continue
        # 截断 ER 之后内容（防止污染）
        p = re.split(r"\nER\s*", p)[0]
        p = p.strip()
        # 重建标准 ER
        p += "\nER"
        records.append(p)
    return records
# =========================
# 5. 合并所有文件
# =========================
all_records = []
for file in selected_files:
    path = os.path.join(folder_path, file)
    if not os.path.exists(path):
        print("❌ 文件不存在:", file)
        continue
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        text = f.read()
    recs = parse_wos(text)
    all_records.extend(recs)
# =========================
# 6. 去重（稳定版）
# =========================
unique_records = list(dict.fromkeys(all_records))
# =========================
# 7. 写出
# =========================
with open(output_file, "w", encoding="utf-8") as f:
    for r in unique_records:
        f.write(r + "\n\n")
# =========================
# 8. 输出统计
# =========================
print("========== 完成 ==========")
print("合并前:", len(all_records))
print("去重后:", len(unique_records))
print("输出文件:", output_file)
