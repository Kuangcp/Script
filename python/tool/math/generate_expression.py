import random


def generate():
    for i in range(1, 20):
        a = random.randint(1000, 10000)
        b = random.randint(3, 9)

        result = a * b
        str_a = str(a)
        str_result = str(result)
        indexes = []
        while len(indexes) < 4:
            index = random.randint(1, 4)
            index *= -1
            if index in indexes:
                continue
            indexes.append(index)
            if len(indexes) <= 2:
                tmp = list(str_a)
                tmp[index] = 'x'
                str_a = ''.join(tmp)
            else:
                tmp = list(str_result)
                tmp[index] = 'x'
                str_result = ''.join(tmp)
        # print(indexes)
        print("%-3d题:\n%5s\nx%4s\n-----\n%5s\n\n\n" %
              (i, str_a, b, str_result))


generate()