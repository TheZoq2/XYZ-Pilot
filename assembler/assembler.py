from sys import argv

from compiler.qd_compiler import QuickAndDirtyCompiler


def main():
    if len(argv) > 1:
        filename = argv[1]
    else:
        filename = 'test.asm'

    compiler = QuickAndDirtyCompiler(filename)
    compiler.compile()

if __name__ == "__main__":
    main()
