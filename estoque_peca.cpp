// ============================================================
// CONTROLE DE ESTOQUE DE PECAS DA OFICINA (versao C++)
// Usa: cout, cin, if, for, while, funcoes, recursividade,
// vetor, ponteiro, deque e set.
// Compilar: g++ estoque_pecas.cpp -o estoque_pecas
// ============================================================

#include <iostream>
#include <string>
#include <vector>
#include <deque>
#include <set>
#include <cstdlib>   // system()
using namespace std;

struct Peca {
    int codigo;
    string nome;
    int quantidade;
};

vector<Peca> estoque;            // pecas da oficina
set<int> codigosCadastrados;     // set evita codigo repetido
deque<string> historico;         // ultimas movimentacoes

// ---------- Limpar a tela ----------
void limparTela() {
#ifdef _WIN32
    system("cls");     // Windows
#else
    system("clear");   // Linux / Mac
#endif
}

// ---------- Leitura segura ----------
int lerInt() {
    int x;
    while (!(cin >> x)) {
        cin.clear();
        cin.ignore(1000, '\n');
        cout << "Valor invalido. Tente de novo: ";
    }
    return x;
}

// ---------- Historico (deque guarda so as 5 ultimas) ----------
void registrarHistorico(string texto) {
    historico.push_back(texto);
    if (historico.size() > 5) {
        historico.pop_front();   // remove a mais antiga
    }
}

// ---------- Ponteiro: localizar peca ----------
Peca* localizarPeca(int codigo) {
    for (int i = 0; i < (int)estoque.size(); i++) {
        if (estoque[i].codigo == codigo) {
            return &estoque[i];
        }
    }
    return nullptr;   // nao encontrou
}

// ---------- Recursividade: total de unidades em estoque ----------
int totalUnidades(int pos) {
    if (pos >= (int)estoque.size()) return 0;
    return estoque[pos].quantidade + totalUnidades(pos + 1);
}

// ---------- Operacoes ----------
bool adicionarPeca(int codigo, string nome, int quantidade) {
    if (codigosCadastrados.count(codigo) > 0 || quantidade < 0) {
        return false;
    }
    Peca p;
    p.codigo = codigo;
    p.nome = nome;
    p.quantidade = quantidade;
    estoque.push_back(p);
    codigosCadastrados.insert(codigo);
    return true;
}

bool realizarBaixa(int codigo, int qtd) {
    Peca* p = localizarPeca(codigo);
    if (p == nullptr || qtd <= 0) {
        return false;
    }
    if (p->quantidade >= qtd) {
        p->quantidade -= qtd;
        registrarHistorico("Baixa: " + to_string(qtd) + " x " + p->nome);
        return true;
    }
    return false;
}

bool reporPeca(int codigo, int qtd) {
    Peca* p = localizarPeca(codigo);
    if (p == nullptr || qtd <= 0) {
        return false;
    }
    p->quantidade += qtd;
    registrarHistorico("Reposicao: " + to_string(qtd) + " x " + p->nome);
    return true;
}

// ---------- Telas ----------
void mostrarEstoque() {
    cout << "\n--- Estoque atual ---\n";
    for (int i = 0; i < (int)estoque.size(); i++) {
        cout << estoque[i].codigo << " - " << estoque[i].nome
             << ": " << estoque[i].quantidade << " unidades\n";
    }
    cout << "Total de unidades: " << totalUnidades(0) << "\n";
}

void mostrarHistorico() {
    cout << "\n--- Ultimas movimentacoes ---\n";
    if (historico.empty()) cout << "Nenhuma movimentacao ainda.\n";
    for (int i = 0; i < (int)historico.size(); i++) {
        cout << i + 1 << ". " << historico[i] << "\n";
    }
}

void telaBaixa() {
    cout << "Codigo da peca: ";
    int codigo = lerInt();
    cout << "Quantidade solicitada: ";
    int qtd = lerInt();
    if (realizarBaixa(codigo, qtd)) {
        cout << "Baixa realizada com sucesso.\n";
    } else {
        cout << "Peca nao encontrada ou estoque insuficiente.\n";
    }
}

void telaReposicao() {
    cout << "Codigo da peca: ";
    int codigo = lerInt();
    cout << "Quantidade a repor: ";
    int qtd = lerInt();
    if (reporPeca(codigo, qtd)) {
        cout << "Reposicao realizada com sucesso.\n";
    } else {
        cout << "Peca nao encontrada ou quantidade invalida.\n";
    }
}

void telaCadastro() {
    cout << "Codigo da nova peca: ";
    int codigo = lerInt();
    cout << "Nome da peca: ";
    cin.ignore(1000, '\n');      // descarta o Enter anterior
    string nome;
    getline(cin, nome);          // aceita nome com espacos
    cout << "Quantidade inicial: ";
    int qtd = lerInt();
    if (adicionarPeca(codigo, nome, qtd)) {
        cout << "Peca cadastrada com sucesso.\n";
    } else {
        cout << "Codigo ja existe ou quantidade invalida.\n";
    }
}

// ---------- Programa principal ----------
int main() {
    adicionarPeca(101, "Filtro de oleo", 12);
    adicionarPeca(102, "Pastilha de freio", 8);
    adicionarPeca(103, "Filtro de ar", 5);

    int opcao = -1;
    while (opcao != 0) {
        cout << "\n===== ESTOQUE DE PECAS =====\n";
        cout << "1 - Ver estoque\n";
        cout << "2 - Dar baixa em peca\n";
        cout << "3 - Repor peca\n";
        cout << "4 - Cadastrar nova peca\n";
        cout << "5 - Ver ultimas movimentacoes\n";
        cout << "6 - Limpar tela\n";
        cout << "0 - Sair\n";
        cout << "Escolha: ";
        opcao = lerInt();

        if (opcao == 1) mostrarEstoque();
        else if (opcao == 2) telaBaixa();
        else if (opcao == 3) telaReposicao();
        else if (opcao == 4) telaCadastro();
        else if (opcao == 5) mostrarHistorico();
        else if (opcao == 6) limparTela();
        else if (opcao == 0) cout << "Encerrando o sistema...\n";
        else cout << "Opcao invalida.\n";
    }
    return 0;
}
