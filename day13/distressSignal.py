
import sys
import json

def checkOrdering( filePath ):

    f = open( filePath, "r")
    lines = f.read()

    lines = lines.split("\n")
    nLines = len( lines )

    nPairs = 0
    nLessThan2 = 1
    # [[2]] < [[6]] but not in data
    nLessThan6 = 2

    counter = 1
    for ii in range( 0, nLines, 3):

        lineLeft = lines[ii]
        lineRight = lines[ii + 1]

        lineLeft = json.loads( lineLeft )
        lineRight = json.loads( lineRight )

        valid_ii = compareLines( lineLeft, lineRight)

        valid_left_2 = compareLines( lineLeft, [[2]])
        valid_right_2 = compareLines( lineRight, [[2]])

        valid_left_6 = compareLines( lineLeft, [[6]])
        valid_right_6 = compareLines( lineRight, [[6]])

        valid_ii = max( valid_ii, 0)
        nPairs += counter * valid_ii

        nLessThan2 += max( valid_left_2, 0)
        nLessThan2 += max( valid_right_2, 0)

        nLessThan6 += max( valid_left_6, 0)
        nLessThan6 += max( valid_right_6, 0)

        counter += 1

    print( nPairs )
    print( nLessThan2 * nLessThan6 )

def compareLines( left, right):
    # Thanks Eetu and Totti for the much cleaner version

    order = 0

    if type(left) is int and type(right) is not int:
            left = [left]
    elif type(right) is int and type(left) is not int:
            right = [right]

    if type(left) is int:
        order = right - left

        if order > 0:
            order = 1
        elif order < 0:
            order = -1
    
    else:

        nLeft = len( left )
        nRight = len( right )

        # If either one or both of the lists are empty
        if nRight == 0 and nLeft > 0:
            order = -1
        elif nLeft == 0 and nRight > 0:
            order = 1
        elif nLeft == nRight == 0: 
            # idea for shortening the notation by Totti Sillanpää
            order = 0
        else:
            for ii in range( nLeft ):
                order = compareLines( left[ii], right[ii])
                if order != 0:
                    break
                if nRight == ii + 1 and nLeft > ii + 1:
                    order = -1
                    break
                elif nLeft == ii + 1 and nRight > ii + 1:
                    order = 1
                    break


    return order

if __name__ == '__main__':
    
    filePath = sys.argv[1]
    checkOrdering( filePath )
    