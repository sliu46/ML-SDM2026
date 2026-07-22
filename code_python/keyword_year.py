import pandas as pd
from collections import defaultdict


# =========================
# 1. 读取Excel
# =========================

input_file = r"F:\PythonItem\bib\FirstRevire6.29\SearchWords\DataSplit\paperMessage.xlsx"

df = pd.read_excel(input_file)


print(df.columns)


# =========================
# 2. 查看年份和关键词字段
# =========================

# 假设字段：
# PY = 年份
# DE = 作者关键词

year_col = "PY"
keyword_col = "DE"



# =========================
# 3. 统计结构
# =========================

keyword_year = defaultdict(
    lambda: defaultdict(int)
)



# =========================
# 4. 遍历文章
# =========================

for _, row in df.iterrows():

    year = row[year_col]


    # 年份过滤
    if pd.isna(year):
        continue


    year = int(year)


    if year < 2006 or year > 2026:
        continue



    keywords = row[keyword_col]


    if pd.isna(keywords):
        continue



    # =====================
    # DE关键词拆分
    # =====================

    kws = str(keywords).split(";")



    for kw in kws:

        kw = kw.strip().lower()


        if kw:

            keyword_year[kw][year] += 1



# =========================
# 5. 转换为矩阵
# =========================


result = pd.DataFrame(keyword_year).fillna(0)


# 年份作为列
result = result.T


result.index.name = "Keyword"


# 排序年份

result = result.reindex(
    sorted(result.columns),
    axis=1
)


result = result.astype(int)



# =========================
# 6. 输出
# =========================

output_file = (
    r"keyword_year_frequency_DE.csv"
)


result.to_csv(
    output_file,
    encoding="utf-8-sig"
)


print("完成")
print("关键词数量:",len(result))
print("输出:",output_file)

print(result.head())