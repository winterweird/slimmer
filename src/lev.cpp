#include <iostream>
#include <vector>

#define min(a, b) (a < b ? a : b)

using namespace std;

// Ref: https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_full_matrix
int levenshtein(string s, string t) {
    vector<vector<unsigned long long>> d(s.size() + 1, vector<unsigned long long>(t.size()+1, 0));
    for (int i = 1; i <= s.size(); i++) d[i][0] = i;
    for (int i = 1; i <= t.size(); i++) d[0][i] = i;
    for (int j = 1; j <= t.size(); j++) for (int i = 1; i <= s.size(); i++) d[i][j] = min(d[i-1][j] + 1, min(d[i][j-1] + 1, d[i-1][j-1] + (s[i-1] != t[j-1])));
    return d[s.size()][t.size()];
}

int main(int argc, char** argv) {
    string s1, s2;
    if (argc == 1) {
        getline(cin, s1);
        getline(cin, s2);
    }
    else if (argc == 3) {
        s1 = string(argv[1]);
        s2 = string(argv[2]);
    }
    else {
        cerr << "Usage: " << argv[0] << " <string1> <string2>"  << endl;
        return 1;
    }
    cout << levenshtein(s1, s2) << endl;
}
