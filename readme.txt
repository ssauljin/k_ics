1. 메인코드들은 여러개의 R 파일로 구성되어 있는데, 기본적으로는 같은 구조를 가집니다.
파일명: K-ICS_analysis (J=샘플갯수, true=실제 자료생성 구조, N=샘플 사이즈).R

다음은 메인코드 안에 있는 단락들에 대한 설명입니다.

#### Generation of hypothetical population data for dependent risks   ####
자료생성 구조를 분포가정에 따라 준 뒤, 실제 개별위험과 결합위험의 모집단 분포를 생성합니다.

#### VaR estimation with sample size of ??? (one can replace ??? with any number, say…)####
모집단과 동일한 분포를 갖는 샘플을 J개 생성한 뒤에, 각각의 샘플에 대해 표준모형/자료의존/내부모형1/내부모형2를 적용하여 VaR을 산출합니다. 해당 결과들은 길이가 J인 다음 벡터들에 저장되고,
prd[J].vstd / prd[J].vemp / prd[J].varc / prd[J].velp /
표 1,2,3과 그림 1,2,3을 작성하는데 사용됩니다.

분석이 끝나면 결과값들은 K-ICS_analysis (J=샘플갯수, true=실제 자료생성 구조, N=샘플 사이즈).RData에 저장됩니다.

2. 저장된 분석결과값들은 K-ICS_summary (N=n).R파일을 통하여 표 또는 그림으로 요약할 수 있습니다.
