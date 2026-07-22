import re
import pandas as pd
import pycountry
from itertools import combinations
from collections import defaultdict

# =========================
# 1. 读取 WoS txt 文件
# =========================
file_path = r"F:\PythonItem\bib\FirstRevire6.29\SearchWords\DataSplit\06-25(5224).txt"

with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
    text = f.read()

# 按文章分割
records = text.split("\nER\n")

# =========================
# 2. 国家标准化函数（核心）
# =========================
def standard_country(name):
    if not name:
        return None

    name = name.strip().replace(".", "")

    # ---------- 1. 常见国家手动修正 ----------
    manual_map = {
        "USA": "United States",
        "U S A": "United States",
        "US": "United States",
        "UK": "United Kingdom",
        "England": "United Kingdom",
        "Scotland": "United Kingdom",
        "PR China": "China",
        "People's Republic of China": "China",
        "Hong Kong": "Hong Kong"
    }

    if name in manual_map:
        return manual_map[name]

    # ---------- 2. pycountry匹配 ----------
    try:
        return pycountry.countries.lookup(name).name
    except:
        return None


# =========================
# 3. 从 C1 提取国家（关键修复版）
# =========================
def extract_countries(c1_text):
    countries = set()

    lines = c1_text.split("\n")

    for line in lines:
        line = line.strip()

        if not line:
            continue

        # ---------- 强规则：只识别真正国家 ----------
        # WoS里国家通常是最后一个字段，但必须验证

        # 1. 如果包含 USA
        if "USA" in line or "U S A" in line:
            countries.add("United States")
            continue

        # 2. 如果包含 UK
        if "England" in line or "UK" in line:
            countries.add("United Kingdom")
            continue

        # 3. 如果包含 China
        if "China" in line:
            countries.add("China")
            continue

        # 4. 其他情况：取最后一段，但必须过滤数字（避免 IA 50614）
        parts = line.split(",")

        if len(parts) > 1:
            candidate = parts[-1].strip()

            # ❌ 过滤邮编/州
            if any(char.isdigit() for char in candidate):
                continue

            std = standard_country(candidate)

            if std:
                countries.add(std)

    return list(countries)


# =========================
# 4. 提取所有论文国家
# =========================
all_papers = []

for rec in records:
    if "C1" not in rec:
        continue

    match = re.search(r"C1 (.*?)C3", rec, re.S)

    if match:
        c1_text = match.group(1)
        countries = extract_countries(c1_text)

        if len(countries) > 0:
            all_papers.append(countries)

# =========================
# 5. 构建国家-国家合作矩阵
# =========================
co_matrix = defaultdict(lambda: defaultdict(int))

for countries in all_papers:
    countries = sorted(set(countries))

    for c1, c2 in combinations(countries, 2):
        co_matrix[c1][c2] += 1
        co_matrix[c2][c1] += 1

# =========================
# 6. 转 DataFrame
# =========================
df = pd.DataFrame(co_matrix).fillna(0)

# 对角线清零
for c in df.columns:
    df.loc[c, c] = 0

# =========================
# 7. 保存结果
# =========================
output_path = r"country_coauthorship_FINAL.csv"
df.to_csv(output_path, encoding="utf-8-sig")

print("✅ 国家合作矩阵构建完成！")
print("国家数量：", len(df.columns))
print("输出路径：", output_path)