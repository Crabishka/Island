import 'dart:collection';

import 'test_data.dart';

class ResultData {
  final int count;
  final int maxSize;

  const ResultData(this.count, this.maxSize);

  @override
  String toString() => 'ResultData(count: $count, maxSize: $maxSize)';

  @override
  bool operator ==(Object other) => other is ResultData && count == other.count && maxSize == other.maxSize;

  @override
  int get hashCode => Object.hash(count, maxSize);
}

void main() async {
  test();
}

void test() {
  testNumIslands(grid: grid1, desc: 'Grid 1', estimatedResult: const ResultData(1, 1));
  testNumIslands(grid: grid2, desc: 'Grid 2', estimatedResult: const ResultData(0, 0));
  testNumIslands(grid: grid3, desc: 'Grid 3', estimatedResult: const ResultData(10, 1));
  testNumIslands(grid: grid4, desc: 'Grid 4', estimatedResult: const ResultData(0, 0));
  testNumIslands(grid: grid5, desc: 'Grid 5', estimatedResult: const ResultData(1, 20));
  testNumIslands(grid: grid6, desc: 'Grid 6', estimatedResult: const ResultData(1, 19));
  testNumIslands(grid: grid7, desc: 'Grid 7', estimatedResult: const ResultData(1, 9));
  testNumIslands(grid: grid8, desc: 'Grid 8', estimatedResult: const ResultData(2, 6));
  testNumIslands(grid: grid9, desc: 'Grid 9', estimatedResult: const ResultData(3, 3));
  testNumIslands(grid: grid10, desc: 'Grid 10', estimatedResult: const ResultData(0, 0));
  testNumIslands(grid: grid11, desc: 'Grid 11', estimatedResult: const ResultData(8, 6));
}

void testNumIslands({required List<List<String>> grid, required ResultData estimatedResult, String desc = ''}) {
  final dfsResult = numIslands(grid: grid, isBFS: false);
  final bfsResult = numIslands(grid: grid, isBFS: true);

  if (bfsResult == estimatedResult) {
    print('BFS $desc passed');
  } else {
    print('BFS $desc failed, BFS result is $bfsResult, estimate is $estimatedResult');
  }
  if (dfsResult == estimatedResult) {
    print('DFS $desc passed');
  } else {
    print('DFS $desc failed, DFS result is $dfsResult, estimate is $estimatedResult');
  }
}

ResultData numIslands({required List<List<String>> grid, bool isBFS = true}) {
  if (grid.isEmpty || grid[0].isEmpty) return const ResultData(0, 0);
  if (isBFS) {
    return numIslandsBFS(grid: grid);
  }
  return numIslandsDFS(grid: grid);
}

/// основная идея DFS - пройтись по всем элементам, при нахождении 1 - начать поиск в глубину.
/// Во время поиска в глубину мы помечаем все ячейки как visited,
/// и при дальнейшем поиске островов, игнорируем их, так как они уже являются частью какого либо острова или 0
///
/// Временная сложность будет O(m*n), так как мы проходимся по всем элементам таблицы, но не попадаем в уже посещенные.
/// *Тут нужно отметить, что в цикле мы все равно делаем проверку на visited по всей таблице
/// и в худшем варианте (когда у нас один остров на всю таблицу) точная оценка будет 2*m*n (без учета количества создаваемых рекурсивных методов),
/// но в оценке сложности константа отбрасывается*
///
/// Пространственная сложность  будет O(m*n), так как мы храним дополнительную таблицу n*m для посещенных
///
/// Размера острова можно считать сразу в проходе в глубину
ResultData numIslandsDFS({required List<List<String>> grid}) {
  final rows = grid.length;
  final cols = grid[0].length;
  final visited = List.generate(rows, (_) => List<bool>.filled(cols, false));

  int dfs(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return 0;
    if (grid[row][col] == "0" || visited[row][col]) return 0;
    visited[row][col] = true;
    var size = 1;
    size += dfs(row + 1, col);
    size += dfs(row - 1, col);
    size += dfs(row, col + 1);
    size += dfs(row, col - 1);
    return size;
  }

  var count = 0;
  var maxSize = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      if (grid[row][col] == "1" && !visited[row][col]) {
        final size = dfs(row, col);
        count++;
        if (size > maxSize) {
          maxSize = size;
        }
      }
    }
  }
  return ResultData(count, maxSize);
}

/// основная идея BFS - так же пройтись по всем элементам, при нахождении 1 - начинать BFS,
/// то есть смотреть на всех соседей, потом на соседей соседей и т.д.
/// Во время прохода мы портим начальную таблицу, чтобы уложиться в ограничения по памяти (помечаем пройденные острова как -1).
/// В дальнейшем мы можем восстановить начальную таблицу просто заменив -1 на 1.
///
/// Временная сложность - так же как у DFS O(m*n), так как мы проходимся по всем ячейкам, но в отличие от DFS у нас нет рекурсивных вызовов,
/// но мы также тратим еще O(n*m) на восстановление таблицы
/// Пространственная сложность - O(min(m,n)), мы храним только очередь соседей и для пометки используем начальную таблицу, которую потом восстанавливаем.
/// Очередь не может быть больше чем наименьшая сторона, потому что поиск как бы распространяется ромбом, а в нашем случае ромб обрезан наименьшей границей.
///
/// Размера острова считаем сразу при проходе в ширину
ResultData numIslandsBFS({required List<List<String>> grid}) {
  final rows = grid.length;
  final cols = grid[0].length;

  int bfs(int sourceRow, int sourceCol) {
    /// если мы уже были тут - сразу выходим
    if (grid[sourceRow][sourceCol] == "-1") {
      return -1;
    }

    /// очередь неосмотренных ячеек, сразу добавляем начальную
    final q = Queue<List<int>>();
    q.add([sourceRow, sourceCol]);
    grid[sourceRow][sourceCol] = "-1";
    var size = 0;

    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    /// добавляем всех соседей в очередь, если это остров
    ///
    while (q.isNotEmpty) {
      final cur = q.removeFirst();
      final row = cur[0];
      final col = cur[1];
      size++;

      /// отсматриваем всех соседей по сторонам
      for (final dir in dirs) {
        final currRow = row + dir[0];
        final currCol = col + dir[1];
        final isNotOutOfBounds = currRow >= 0 && currRow < rows && currCol >= 0 && currCol < cols;

        /// если клетка в границах и остров - добавляем ее в очередь
        if (isNotOutOfBounds && grid[currRow][currCol] == "1") {
          /// сразу помечаем ее как -1, чтобы другие соседи ее не тронули
          grid[currRow][currCol] = "-1";
          q.add([currRow, currCol]);
        }
      }
    }
    return size;
  }

  var count = 0;
  var maxSize = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      if (grid[row][col] == "1") {
        final size = bfs(row, col);
        if (size > maxSize) {
          maxSize = size;
        }
        count++;
      }
    }
  }
  recoverGrid(grid: grid);
  return ResultData(count, maxSize);
}

/// так как мы портим табличку при BFS - восстанавливаем ее
void recoverGrid({required List<List<String>> grid}) {
  final rows = grid.length;
  final cols = grid[0].length;

  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (grid[r][c] == "-1") {
        grid[r][c] = "1";
      }
    }
  }
}
